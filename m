From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: fix comment above build_skb()
Date: Tue, 23 Jul 2013 11:54:22 -0700
Message-ID: <1374605662.3449.49.camel@edumazet-glaptop>
References: <1374593943-31642-1-git-send-email-f.fainelli@gmail.com>
	 <1374594559.3449.17.camel@edumazet-glaptop>
	 <CAGVrzcZ6=591=sY6kVVrwy4BHN_0LoMZ=u2yz88QyBUvtSOydA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:46212 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933293Ab3GWSyY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 14:54:24 -0400
Received: by mail-pa0-f54.google.com with SMTP id kx10so8723702pab.13
        for <netdev@vger.kernel.org>; Tue, 23 Jul 2013 11:54:24 -0700 (PDT)
In-Reply-To: <CAGVrzcZ6=591=sY6kVVrwy4BHN_0LoMZ=u2yz88QyBUvtSOydA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-07-23 at 19:04 +0100, Florian Fainelli wrote:

> Sure, would something like:
> 
> "@data must have been allocated by kmalloc() if frag_size is 0,
> otherwise any data buffer (vmalloc, DMA..) is suitable"
> 

Actually not, the other case must be a page frag, because we are going
to use get_page() and put_page() during skb lifetime.

netlink case is really special/hacky, because it makes sure those
get_page()/put_page() calls wont ever happen.
