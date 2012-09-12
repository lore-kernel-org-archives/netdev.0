From: Aki Parviainen <aki.parviainen@iki.fi>
Subject: Re: [PATCH] staging: r8712u: fix bug in r8712_recv_indicatepkt()
Date: Wed, 12 Sep 2012 20:52:14 +0300
Message-ID: <CAKNFNKoowxSsbkV_tsBDG1uZeuWBDxPQFQoHQZ2R2O7Y6hnrmA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:53976 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760641Ab2ILRwQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2012 13:52:16 -0400
Received: by lbbgj3 with SMTP id gj3so1347543lbb.19
        for <netdev@vger.kernel.org>; Wed, 12 Sep 2012 10:52:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From: Eric Dumazet <edumazet@google.com>
>
>64bit arches have a buggy r8712u driver, let's fix it.
>
>skb->tail must be set properly or network stack behavior is undefined.
>
>Addresses https://bugzilla.redhat.com/show_bug.cgi?id=847525
>Addresses https://bugzilla.kernel.org/show_bug.cgi?id=45071
>
>Signed-off-by: Eric Dumazet <edumazet@google.com>
>Cc: Larry Finger <Larry.Finger@lwfinger.net>
>Cc: Dave Jones <davej@redhat.com>
>Cc: stable@vger.kernel.org [2.6.37+]

Tested this patch on 64bit linux-3.6-rc5 & fixes problem for me. Thank
you very much for fixing this very annoying & long time open bug!

Tested-by: Aki Parviainen <aki.parviainen@iki.fi>

Aki

>---
> drivers/staging/rtl8712/recv_linux.c |    7 +------
> 1 file changed, 1 insertion(+), 6 deletions(-)
>
>diff --git a/drivers/staging/rtl8712/recv_linux.c b/drivers/staging/rtl8712/recv_linux.c
>index 0e26d5f..495ee12 100644
>--- a/drivers/staging/rtl8712/recv_linux.c
>+++ b/drivers/staging/rtl8712/recv_linux.c
>@@ -117,13 +117,8 @@ void r8712_recv_indicatepkt(struct _adapter *padapter,
>  if (skb == NULL)
>  goto _recv_indicatepkt_drop;
>  skb->data = precv_frame->u.hdr.rx_data;
>-#ifdef NET_SKBUFF_DATA_USES_OFFSET
>- skb->tail = (sk_buff_data_t)(precv_frame->u.hdr.rx_tail -
>-     precv_frame->u.hdr.rx_head);
>-#else
>- skb->tail = (sk_buff_data_t)precv_frame->u.hdr.rx_tail;
>-#endif
>  skb->len = precv_frame->u.hdr.len;
>+ skb_set_tail_pointer(skb, skb->len);
>  if ((pattrib->tcpchk_valid == 1) && (pattrib->tcp_chkrpt == 1))
>  skb->ip_summed = CHECKSUM_UNNECESSARY;
>  else
