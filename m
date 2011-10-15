From: RongQing Li <roy.qing.li@gmail.com>
Subject: Re: [PATCH net-next] skbuff: update sk truesize in pskb_expand_head
Date: Sat, 15 Oct 2011 11:54:38 +0800
Message-ID: <CAJFZqHyGPUZqAdoZ0MygD6nx0T+kZAQ+hZ2ZFNV62SVkTjSpvw@mail.gmail.com>
References: <1318577970-19566-1-git-send-email-roy.qing.li@gmail.com>
	<1318578829.2533.100.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:44849 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754910Ab1JODyj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2011 23:54:39 -0400
Received: by pzk1 with SMTP id 1so6937674pzk.1
        for <netdev@vger.kernel.org>; Fri, 14 Oct 2011 20:54:39 -0700 (PDT)
In-Reply-To: <1318578829.2533.100.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/10/14 Eric Dumazet <eric.dumazet@gmail.com>:
> Le vendredi 14 octobre 2011 =E0 15:39 +0800, roy.qing.li@gmail.com a
> =E9crit :
>
> I dont believe this is needed or complete patch.
>
> Callers that need an updated truesize do the adjustement.
>

If we think the size which needs to adjust is small, we can ignore it,
I accept it.

if Let caller to adjust it, I think the caller is hard to get the adjus=
tment.

Do you think the below adjustment is needed?

void skb_add_rx_frag(struct sk_buff *skb, int i, struct page *page, int=
 off,
		int size)
{
	skb_fill_page_desc(skb, i, page, off, size);
	skb->len +=3D size;
	skb->data_len +=3D size;
-	skb->truesize +=3D size;
+	skb->truesize +=3D PAGE_SIZE;
}

Thanks
-Qing
