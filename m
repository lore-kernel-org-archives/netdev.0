From: Thomas Graf <tgraf@suug.ch>
Subject: Re: update frequency for stats in /proc/net/dev
Date: Tue, 18 Dec 2007 15:57:07 +0100
Message-ID: <20071218145707.GV11220@postel.suug.ch>
References: <4767CD16.5050904@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Mark Seger <Mark.Seger@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:53829 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756175AbXLRO4r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Dec 2007 09:56:47 -0500
Content-Disposition: inline
In-Reply-To: <4767CD16.5050904@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Mark Seger <Mark.Seger@hp.com> 2007-12-18 08:37
> Anyhow, I just wanted to let people know that ALL tools that monitor 
> once a second on older counters will get the wrong numbers and tools 
> that correct for the wrong number by using fractional intervals (and I 
> suspect mine is the only one that does) but run on newer kernels will 
> also get the wrong numbers.  In any event, if anyone is interested in 
> trying out collectl - it monitors a  LOT more than just networks - you 
> can snag a copy of from http://collectl.sourceforge.net/ if you'd like 
> to take if for a drive.  The website has a lot of output examples to 
> give you a better idea what it can do.  I even included a writeup about 
> the odd network performance observations at 
> http://collectl.sourceforge.net/NetworkStats.html

I've solved this problem by using netlink to read the interface counters
ten times per second and maintain an own counter from which I calculate
the rate exactly once per second/minute/hour. The rate per second may
still be inaccurate to some degree, therefore I keep a history of 2-5
rates and take them into account to smoothen the result. This works
fairly well with _all_ operating systems.
