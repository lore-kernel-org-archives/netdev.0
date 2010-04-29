From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH net-next-2.6] net: speedup udp receive path
Date: Thu, 29 Apr 2010 09:17:41 -0400
Message-ID: <1272547061.4258.174.camel@bigi>
References: <1272010378-2955-1-git-send-email-xiaosuo@gmail.com>
	 <20100427.150817.84390202.davem@davemloft.net>
	 <1272406693.2343.26.camel@edumazet-laptop>  <1272454432.14068.4.camel@bigi>
	 <1272458001.2267.0.camel@edumazet-laptop>  <1272458174.14068.16.camel@bigi>
	 <1272463605.2267.70.camel@edumazet-laptop> <1272498293.4258.121.camel@bigi>
	 <1272514176.2201.85.camel@edumazet-laptop> <1272540952.4258.161.camel@bigi>
	 <u2l412e6f7f1004290512x7fcdb5c3w591c6446d676502@mail.gmail.com>
	 <1272545108.2222.65.camel@edumazet-laptop>
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
Received: from mail-iw0-f182.google.com ([209.85.223.182]:55735 "EHLO
	mail-iw0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933832Ab0D3SMJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 14:12:09 -0400
Received: by mail-iw0-f182.google.com with SMTP id 12so556036iwn.15
        for <netdev@vger.kernel.org>; Fri, 30 Apr 2010 11:12:08 -0700 (PDT)
In-Reply-To: <1272545108.2222.65.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-04-29 at 14:45 +0200, Eric Dumazet wrote:

> 
> Changli, I wonder how you can cook "performance" patches without testing
> them at all for real... This cannot be true ?

Eric, I am with you, however you are in the minority of people who test
and produce numbers ;-> The system rewards people for sending patches
not much for anything else - so i cant blame Changli ;->

> When the cpu doing the device softirq is flooded, it handles 300 packets
> per net_rx_action() round (netdev_budget), so sends at most 6 ipis per
> 300 packets, with or without my patch, with or without your patch as
> well.
> 
> (At most because if remote cpus are flooded as well, they dont
> napi_complete so no IPI needed at all)
>
> (My patch had an effect only on normal load, ie one packet received in a
> while... up to 50.000 pps I would say). And it also has a nice effect on
> non RPS loads (mostly the more typical load for following years).
> If a second packet comes 3us after the first one, and before 2nd CPU
> handled it, we _can_ afford an extra IPI.
> 
> 750.000/50 = 15.000 IPI per second.

Could we have some stat in there that shows IPIs being produced? I think
it would help to at least observe any changes over variety of tests.
I did try to patch my system during the first few tests to record IPIs
but it seems to make more sense to have it as a perf stat.

> Even with 200.000 IPI per second, 'perf top -C CPU_IPI_sender' shows
> that sending IPI is very cheap (maybe ~1% of cpu cycles)
> 
> # Samples: 32033467127
> #

One thing i observed is our profiles seem different. Could you send me
your .config for a single nehalem and i will try to go as close as
possible to it? I have a sky2 instead of bnx - but i suspect everything
else will be very similar...
I apologize i dont have much time to look into details - but what i can
do is test at least.

cheers,
jamal



