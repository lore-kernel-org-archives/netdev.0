From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH net-next-2.6] net: speedup udp receive path
Date: Thu, 29 Apr 2010 09:56:48 -0400
Message-ID: <1272549408.4258.189.camel@bigi>
References: <1272010378-2955-1-git-send-email-xiaosuo@gmail.com>
	 <20100427.150817.84390202.davem@davemloft.net>
	 <1272406693.2343.26.camel@edumazet-laptop>  <1272454432.14068.4.camel@bigi>
	 <1272458001.2267.0.camel@edumazet-laptop>  <1272458174.14068.16.camel@bigi>
	 <1272463605.2267.70.camel@edumazet-laptop> <1272498293.4258.121.camel@bigi>
	 <1272514176.2201.85.camel@edumazet-laptop> <1272540952.4258.161.camel@bigi>
	 <u2l412e6f7f1004290512x7fcdb5c3w591c6446d676502@mail.gmail.com>
	 <1272545108.2222.65.camel@edumazet-laptop> <1272547061.4258.174.camel@bigi>
	 <1272547307.2222.83.camel@edumazet-laptop> <1272548258.4258.185.camel@bigi>
	 <1272548980.2222.87.camel@edumazet-laptop>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Changli Gao <xiaosuo@gmail.com>,
	David Miller <davem@davemloft.net>, therbert@google.com,
	shemminger@vyatta.com, netdev@vger.kernel.org,
	Eilon Greenstein <eilong@broadcom.com>,
	Brian Bloniarz <bmb@athenacr.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f182.google.com ([209.85.223.182]:51222 "EHLO
	mail-iw0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933462Ab0D3SFe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 14:05:34 -0400
Received: by iwn12 with SMTP id 12so547999iwn.15
        for <netdev@vger.kernel.org>; Fri, 30 Apr 2010 11:05:34 -0700 (PDT)
In-Reply-To: <1272548980.2222.87.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-04-29 at 15:49 +0200, Eric Dumazet wrote:

> > I fork one instance per detected cpu and bind to different ports each
> > time. Example bind to port 8200 on cpu0, 8201 on cpu1, etc.
> > 
> 
> I guess this is the problem ;)
> 
> With RPS, you should not bind your threads to cpu.
> This is the rps hash who will decide for you.
> 

Sorry - I was not clear; i have the option of binding to cpu
vs the setsched api; but what i meant in this case is:
- for each cpu detected, fork
-- open socket
---bind to udp port cpu# + 8200

I could also bind to a cpu in the last step and i did notice it
improved distribution - but all my tests since apr23 dont do that ;->

> 
> I am using following program :
> 

I will try your program instead so we can reduce the variables

cheers,
jamal

