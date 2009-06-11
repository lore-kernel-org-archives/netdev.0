From: Anders Eriksson <aeriksson@fastmail.fm>
Subject: Re: WoL and r8169
Date: Thu, 11 Jun 2009 13:14:12 +0200
Message-ID: <20090611111412.C908733C023@tippex.mynet.homeunix.org>
References: <20090607214220.5101B33C013@tippex.mynet.homeunix.org> <20090608215301.GA28044@electric-eye.fr.zoreil.com> <20090610102940.87FE633C023@tippex.mynet.homeunix.org> <20090610230116.GA23440@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Anders Eriksson <aeriksson@fastmail.fm>, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch-smtp01.sth.basefarm.net ([80.76.149.212]:33411 "EHLO
	ch-smtp01.sth.basefarm.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758234AbZFKLOj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 07:14:39 -0400
In-reply-to: <20090610230116.GA23440@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


romieu@fr.zoreil.com said:
> Anders Eriksson <aeriksson@fastmail.fm> : [...]
>> Yes! That diff made the trick for WoL on magic package on my 2.6.30-rc6
>> kernel. Is it sent to Linus for -final?

> No but it does not preclude it being properly submitted thereafter then for
> -stable.

Great.

> [...]
>> I tried to wake up the machine using regular tcp traffic, on the theory that 
>> it's unicast and phy activity. No luck though.

> Did the regular tcp traffic include a so-called magic (tcp) packet ? 

Hmm,no. What is that? I'm looking at having what's best described as "wake on 
directed packet" (ref 8 here, http://en.wikipedia.org/wiki/Wake-on-LAN). 
Afaict, the box is expected to wake up on any traffic directed towards it (its 
MAC and/or IP). 

My reading of ethtool(8) says that 'u' should do the trick, and if I add 'b' I
should be able to wake on arp (as arp is eth broadcast). In my test, however, 
I've made sure to have the arp cache filled, and tcpdump confirms that an ssh 
session to a pm-suspend'd box results in a series of unicsat in-session tcp 
packets, and no arp traffic. Eventullay the arp cache times out (or is pruned 
because of the faild transmissions?) and arp requests happens, but no wakeup.


What's a magic tcp packet?

/Anders 






