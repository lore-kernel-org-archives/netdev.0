From: Tom Herbert <therbert@google.com>
Subject: Re: Bug in computing data_len in tcp_sendmsg?
Date: Wed, 30 Nov 2011 21:09:30 -0800
Message-ID: <CA+mtBx9fE0qQc-LndM03ykhVMV5n9Z4KHcD6PpTiy=M79GOnKw@mail.gmail.com>
References: <CA+mtBx8+sajFaCWqHRr+pY5EAHwN8G61v6cr-HydYhbbdxAgHQ@mail.gmail.com>
	<1322710962.2577.3.camel@edumazet-laptop>
	<CA+mtBx_CUsuGunKONwBNA8qyVni16+RtrRL8w=THYY0mEDcvaA@mail.gmail.com>
	<1322713032.2577.7.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:34157 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750703Ab1LAFJb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 00:09:31 -0500
Received: by iage36 with SMTP id e36so1898710iag.19
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 21:09:31 -0800 (PST)
In-Reply-To: <1322713032.2577.7.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Or the "bug" was to assume that skb was headless.
> It was true until recently.
>
> We recently added commit f07d960df33c5aef
> (tcp: avoid frag allocation for small frames)
>
> to avoid page allocation for small frames.
>
> So now, skb can contain in head part of tcp data.

Yes, reverting that patch seems to fix the problem.  Eric, do you have
an idea what should be used to determine length of headers in an skb
now (mac through transport).
