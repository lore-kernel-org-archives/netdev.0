From: Rick Jones <rick.jones2@hp.com>
Subject: Re: e1000 full-duplex TCP performance well below wire speed
Date: Wed, 30 Jan 2008 10:45:06 -0800
Message-ID: <47A0C5B2.1000500@hp.com>
References: <Pine.LNX.4.63.0801300621290.6391@trinity.phys.uwm.edu> <36D9DB17C6DE9E40B059440DB8D95F52044F81DF@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Bruce Allen <ballen@gravity.phys.uwm.edu>, netdev@vger.kernel.org,
	Carsten Aulbert <carsten.aulbert@aei.mpg.de>,
	Henning Fehrmann <henning.fehrmann@aei.mpg.de>,
	Bruce Allen <bruce.allen@aei.mpg.de>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:35505 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763913AbYA3SpK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2008 13:45:10 -0500
In-Reply-To: <36D9DB17C6DE9E40B059440DB8D95F52044F81DF@orsmsx418.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> As asked in LKML thread, please post the exact netperf command used to
> start the client/server, whether or not you're using irqbalanced (aka
> irqbalance) and what cat /proc/interrupts looks like (you ARE using MSI,
> right?)

In particular, it would be good to know if you are doing two concurrent 
streams, or if you are using the "burst mode" TCP_RR with large 
request/response sizes method which then is only using one connection.

> I've recently discovered that particularly with the most recent kernels
> if you specify any socket options (-- -SX -sY) to netperf it does worse
> than if it just lets the kernel auto-tune.

That is the bit where explicit setsockopts are capped by core [rw]mem 
sysctls but the autotuning is not correct?

rick jones
BTW, a bit of netperf news - the "omni" (two routines to measure it all) 
tests seem to be more or less working now in top of trunk netperf.  It 
of course still needs work/polish, but if folks would like to play with 
them, I'd love the feedback.  Output is a bit different from classic 
netperf, and includes an option to emit the results as csv 
(test-specific -o presently) rather than "human readable" (test-specific 
-O).  You get the omni stuff via ./configure --enable-omni and use 
"omni" as the test name.  No docs yet, for options and their effects, 
you need to look at scan_omni_args in src/nettest_omni.c

One other addition in the omni tests is retreiving not just the initial 
SO_*BUF sizes, but also the final SO_*BUF sizes so one can see where 
autotuning took things just based on netperf output.

If the general concensus is that the overhead of the omni stuff isn't 
too dear, (there are more conditionals in the mainline than with classic 
netperf) I will convert the classic netperf tests to use the omni code.

BTW, don't have a heart attack when you see the quantity of current csv 
output - I do plan on being able to let the user specify what values 
should be included :)
