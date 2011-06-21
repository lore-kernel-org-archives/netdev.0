From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 1/2] udp:  add tracepoints for queueing skb to rcvbuf
Date: Tue, 21 Jun 2011 13:14:36 -0400
Message-ID: <1308676476.531.13.camel@gandalf.stny.rr.com>
References: <65795E11DBF1E645A09CEC7EAEE94B9C402B96E4@USINDEVS02.corp.hds.com>
	 <65795E11DBF1E645A09CEC7EAEE94B9C402B96E5@USINDEVS02.corp.hds.com>
	 <20110621104742.GA16311@hmsreliant.think-freely.org>
	 <4123e3d3ce0192e63947178f249d3411@localhost>
	 <20110621135009.GD16311@hmsreliant.think-freely.org>
	 <5b828bb3667480edda9a4a77918007ee@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Satoru Moriya <satoru.moriya@hds.com>, netdev@vger.kernel.org,
	Seiji Aguchi <seiji.aguchi@hds.com>,
	Ingo Molnar <mingo@elte.hu>
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hrndva-omtalb.mail.rr.com ([71.74.56.125]:62258 "EHLO
	hrndva-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756802Ab1FUROj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2011 13:14:39 -0400
In-Reply-To: <5b828bb3667480edda9a4a77918007ee@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-06-21 at 16:48 +0200, Hagen Paul Pfeifer wrote:
> On Tue, 21 Jun 2011 09:50:09 -0400, Neil Horman wrote:
> 
> > I hadn't really thought about that much, but yes, I suppose I could
> migrate
> > dropwatch to export kfree_skb data via perf.  Admittedly I don't know
> much
> > about
> > the perf api.  Do you have any pointers on its use (to save me time in
> > figuring
> > out how it all works)?  If so I'll start looking into it.
> 
> http://git.kernel.org/?p=status/powertop/powertop.git;a=tree;f=perf;hb=HEAD

Please please do not copy this code and reuse it. You will end up
forcing us to this ABI forever!

Please read this for background:

 http://lwn.net/Articles/442113/

I plan on doing a libperf.so that will allow any tool to interact with
trace events in the kernel the proper way. Yes trace-cmd currently has
its own library that deals with this properly, but the library is not
shipped with distros.

I plan on taking the trace-cmd library (which perf even uses - an older
verion) and make it into the libperf.so that distros will ship. But
unfortunately, my work has gotten in the way (the work that actually
pays me) and I'm doing other things at the moment.

-- Steve

> 
> is probably a good starting point. Especially
> perf_bundle.cpp:handle_trace_point(). But I am not sure if this is the most
> clever way. The direct us of the perf api is somewhat dodgy (not sure if
> the ABI will change). IIRC Steven Rostedt wrote about a user space library
> (I CC'ed Steven). BUT: tracing via /sys/kernel/debug/tracing/* may be
> enough, eventually there is no need for perf at all. Then trace-cmd may
> provide some nice ideas how to wrap the /sys/kernel/debug/tracing interface
> programmatically.
> 
> The idea behind dropwatch is great! There is currently to much
> unconsolidated information. It takes a genius to understand where and later
> why packets are dropped. A userspace tool where no kernel patch is required
> is a big plus! ;-)
> 
> Hagen


