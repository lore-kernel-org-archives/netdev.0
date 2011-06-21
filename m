From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH 1/2] udp:  add tracepoints for queueing skb to rcvbuf
Date: Tue, 21 Jun 2011 16:48:39 +0200
Message-ID: <5b828bb3667480edda9a4a77918007ee@localhost>
References: <65795E11DBF1E645A09CEC7EAEE94B9C402B96E4@USINDEVS02.corp.hds.com>
 <65795E11DBF1E645A09CEC7EAEE94B9C402B96E5@USINDEVS02.corp.hds.com>
 <20110621104742.GA16311@hmsreliant.think-freely.org>
 <4123e3d3ce0192e63947178f249d3411@localhost>
 <20110621135009.GD16311@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Satoru Moriya <satoru.moriya@hds.com>, <netdev@vger.kernel.org>,
	Seiji Aguchi <seiji.aguchi@hds.com>,
	Steven Rostedt <rostedt@goodmis.org>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:49624 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752281Ab1FUOsk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2011 10:48:40 -0400
In-Reply-To: <20110621135009.GD16311@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 21 Jun 2011 09:50:09 -0400, Neil Horman wrote:



> I hadn't really thought about that much, but yes, I suppose I could

migrate

> dropwatch to export kfree_skb data via perf.  Admittedly I don't know

much

> about

> the perf api.  Do you have any pointers on its use (to save me time in

> figuring

> out how it all works)?  If so I'll start looking into it.



http://git.kernel.org/?p=status/powertop/powertop.git;a=tree;f=perf;hb=HEAD



is probably a good starting point. Especially

perf_bundle.cpp:handle_trace_point(). But I am not sure if this is the most

clever way. The direct us of the perf api is somewhat dodgy (not sure if

the ABI will change). IIRC Steven Rostedt wrote about a user space library

(I CC'ed Steven). BUT: tracing via /sys/kernel/debug/tracing/* may be

enough, eventually there is no need for perf at all. Then trace-cmd may

provide some nice ideas how to wrap the /sys/kernel/debug/tracing interface

programmatically.



The idea behind dropwatch is great! There is currently to much

unconsolidated information. It takes a genius to understand where and later

why packets are dropped. A userspace tool where no kernel patch is required

is a big plus! ;-)



Hagen
