From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] staging: r8712u: fix bug in r8712_recv_indicatepkt()
Date: Mon, 10 Sep 2012 14:40:41 -0500
Message-ID: <504E4239.1050700@lwfinger.net>
References: <1347304931.1234.2017.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	netdev <netdev@vger.kernel.org>, Dave Jones <davej@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:56446 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932161Ab2IJTkp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2012 15:40:45 -0400
Received: by ieje11 with SMTP id e11so3957381iej.19
        for <netdev@vger.kernel.org>; Mon, 10 Sep 2012 12:40:44 -0700 (PDT)
In-Reply-To: <1347304931.1234.2017.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/10/2012 02:22 PM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> 64bit arches have a buggy r8712u driver, let's fix it.
>
> skb->tail must be set properly or network stack behavior is undefined.
>
> Addresses https://bugzilla.redhat.com/show_bug.cgi?id=847525
> Addresses https://bugzilla.kernel.org/show_bug.cgi?id=45071
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Larry Finger <Larry.Finger@lwfinger.net>
> Cc: Dave Jones <davej@redhat.com>
> Cc: stable@vger.kernel.org [2.6.37+]

Acked-by: Larry Finger <Larry.Finger@lwfinger.net>

Larry

> ---
>   drivers/staging/rtl8712/recv_linux.c |    7 +------
>   1 file changed, 1 insertion(+), 6 deletions(-)
>
> diff --git a/drivers/staging/rtl8712/recv_linux.c b/drivers/staging/rtl8712/recv_linux.c
> index 0e26d5f..495ee12 100644
> --- a/drivers/staging/rtl8712/recv_linux.c
> +++ b/drivers/staging/rtl8712/recv_linux.c
> @@ -117,13 +117,8 @@ void r8712_recv_indicatepkt(struct _adapter *padapter,
>   	if (skb == NULL)
>   		goto _recv_indicatepkt_drop;
>   	skb->data = precv_frame->u.hdr.rx_data;
> -#ifdef NET_SKBUFF_DATA_USES_OFFSET
> -	skb->tail = (sk_buff_data_t)(precv_frame->u.hdr.rx_tail -
> -		     precv_frame->u.hdr.rx_head);
> -#else
> -	skb->tail = (sk_buff_data_t)precv_frame->u.hdr.rx_tail;
> -#endif
>   	skb->len = precv_frame->u.hdr.len;
> +	skb_set_tail_pointer(skb, skb->len);
>   	if ((pattrib->tcpchk_valid == 1) && (pattrib->tcp_chkrpt == 1))
>   		skb->ip_summed = CHECKSUM_UNNECESSARY;
>   	else
>
>
>
