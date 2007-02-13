From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [patch 3/3] tcp: remove experimental variants from default list
Date: Tue, 13 Feb 2007 12:23:14 -0800
Message-ID: <20070213122314.6968f116@freekitty>
References: <20070212.145351.35661569.davem@davemloft.net>
	<20070213095613.GR25760@galon.ev-en.org>
	<649aecc70702130849s6f70bf37y1f8177060d433ce0@mail.gmail.com>
	<20070213.120640.18311028.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: sangtae.ha@gmail.com, baruch@ev-en.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:51707 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751020AbXBMUX0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Feb 2007 15:23:26 -0500
In-Reply-To: <20070213.120640.18311028.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

My somewhat biased capsule summary is:

Algorithms:

Reno: Linux never really implemented pure Reno anyway, see
	http://www.cs.helsinki.fi/research/iwtcp/papers/linuxtcp.pdf
   This makes anybody doing pure ns2 based comparisons suspect.
   The problem is Reno rolls off

HSTCP: too aggressive and can be unfair
BIC: not fair to Reno
CUBIC: good fairness but depends on additional traffic to converge faster
HTCP: good fairness but high variation
Vegas: reduces loss but sensitive to delay variation and back channel
Westwood: reduces loss but slow growth on high BDP

Not evaluated enough: Hydra, VENO

The biggest issue with CUBIC (and before that BIC) has been 
bugs with a long mean-time-to-discovery (but MTTR has been fast). 
The others don't seem to get as much attention, perhaps
we should turn a different congestion control algorithm as default
on each -mm release to get people to actually look at the others.

There are some newer congestion control algorithms coming:
TCP Illinois, a newer version of Westwood, TCP-Fusion, Exp-TCP
and maybe Adaptive RENO. Stay tuned.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
