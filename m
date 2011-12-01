From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: Bug in computing data_len in tcp_sendmsg?
Date: Thu, 1 Dec 2011 14:18:17 -0800
Message-ID: <CAGK4HS8fLWwdPsrag6+Mz93_ZNg2B5JRjx2s=Re8_Qiv4V=T=w@mail.gmail.com>
References: <CA+mtBx8+sajFaCWqHRr+pY5EAHwN8G61v6cr-HydYhbbdxAgHQ@mail.gmail.com>
	<1322710962.2577.3.camel@edumazet-laptop>
	<CA+mtBx_CUsuGunKONwBNA8qyVni16+RtrRL8w=THYY0mEDcvaA@mail.gmail.com>
	<1322713032.2577.7.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Tom Herbert <therbert@google.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:56789 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754543Ab1LAWSS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 17:18:18 -0500
Received: by vcbfk14 with SMTP id fk14so1900865vcb.19
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2011 14:18:17 -0800 (PST)
In-Reply-To: <1322713032.2577.7.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> Or the "bug" was to assume that skb was headless.
> It was true until recently.
>
> We recently added commit f07d960df33c5aef
> (tcp: avoid frag allocation for small frames)
>
> to avoid page allocation for small frames.
>
> So now, skb can contain in head part of tcp data.
>
>

Hi,
I am looking at tcp_mtu_probe() and was wondering if this commit also
impacts this function. Once the data are copied from skbs in the write
queue to the probe skb, copied data are cleared from the original skbs
in the write queue.

It looks like the code assumes that the original skb will have data
either in linear part or in paged part.  The call to
__pskb_trim_head(skb, copy) for example does not clear linear part.

Can someone more familiar with the code take a look? Apologies if I
have read this wrong.


Regards
Vijay Subramanian
