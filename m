From: Denys Fedorysychenko <nuclearcat@nuclearcat.com>
Subject: Re: HFSC classes going out of bounds, regression in recent kernels?
Date: Thu, 20 May 2010 04:34:27 +0300
Message-ID: <201005200434.28433.nuclearcat@nuclearcat.com>
References: <201004061822.21735.nuclearcat@nuclearcat.com> <4BBB5543.40607@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:43205 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752832Ab0ETBfF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 May 2010 21:35:05 -0400
In-Reply-To: <4BBB5543.40607@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am trying to track down HFSC bug.
It seems, most probably it is related to PSCHED_SHIFT at the end, i am doing 
testing again. I will try to do complete clean build, maybe last time some .o 
was left or i forgot to do make clean.

SM_SHIFT in HFSC is calculated as 30 - PSCHED_SHIFT, and it is shifted too 
much (or not enough) with new changes (ISM_SHIFT seems wrong too). So it is 
most probably overflow or not enough resolution.
I will try to change PSCHED_SHIFT back to confirm that, and at least i found 
way to reproduce bug.

Additionally in sch_hfsc.c i notice mentioned that PSCHED_SHIFT 10 is tick per 
1024us, but i try to calculate their table (in source comments), it doesn't 
fit with my calculations based on 1024us/tick, but fits well with 1024 
nanosecond.

Is it was 1024ns per tick and now 64ns per tick? Or it is microseconds(us) ?
