From: Curt Sampson <cjs@starling-software.com>
Subject: Re: Problems Receiving UDP Broadcasts on Some Versions of Linux
Date: Wed, 27 Jan 2010 14:14:06 +0900
Message-ID: <20100127051405.GA5316@analytic.cynic.net>
References: <20100125072749.GG21419@analytic.cynic.net> <4B5D51E6.5090601@gmail.com> <20100127003744.GA16322@analytic.cynic.net> <1264564565.2810.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-122-103-239-153.ng-fam.svips.gol.ne.jp ([122.103.239.153]:62154
	"EHLO priv.dyadic.cynic.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750993Ab0A0FOL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2010 00:14:11 -0500
Content-Disposition: inline
In-Reply-To: <1264564565.2810.11.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2010-01-27 04:56 +0100 (Wed), Eric Dumazet wrote:

> And you receive a frame on eth1 with src ip address = 192.166.1.120
> 
> I suspect your kernel drops this frame because of asymetric routing
> 
> Check "ip route get 192.166.1.120" and if answer is directed to another interface,
> this may explain the problem.

Indeed, you are absolutely correct. I've further verified that this is
the issue by having the 8.04 host generate broadcast packets on eth0 and
eth1, and the "malfunctioning" 9.04 host receives them correctly in both
cases.

I ought to have known, looking at that patently bogus source address
(there's no way I should be seeing anything to 255.255.255.255 that has
a source address from a different network), to start looking at these
sorts

> Solution : tweak rp_filter settings.

And indeed, that worked. (I've added the old settings to the
StackOverflow page.) Thank you very much!

Let me know (by private e-mail) if you're going to add an answer to my
question on StackOverflow, so I can give you the reputation points.
Otherwise I'll add the answer myself. The URL, again, is:

  http://stackoverflow.com/questions/2130563/udp-broadcast-reception-problems-with-ubuntu-9-04-but-not-8-04

cjs
-- 
Curt Sampson         <cjs@cynic.net>         +81 90 7737 2974
             http://www.starling-software.com
The power of accurate observation is commonly called cynicism
by those who have not got it.    --George Bernard Shaw
