From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v2 0/2] Tracepoint for tcp retransmission
Date: Sun, 5 Feb 2012 20:32:47 -0500
Message-ID: <20120206013247.GA5681@neilslaptop.think-freely.org>
References: <65795E11DBF1E645A09CEC7EAEE94B9CB728DD67@USINDEVS02.corp.hds.com>
 <20120120.135028.1359677274445012541.davem@davemloft.net>
 <65795E11DBF1E645A09CEC7EAEE94B9CB8D3EA7B@USINDEVS02.corp.hds.com>
 <20120204142823.GA7000@neilslaptop.think-freely.org>
 <20120204155807.GA2657@nuttenaction>
 <20120204200937.GA2670@neilslaptop.think-freely.org>
 <20120205125325.GA31578@elastic.org>
 <20120205191708.GA5337@neilslaptop.think-freely.org>
 <20120205200428.GB2816@nuttenaction>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Frank Ch. Eigler" <fche@elastic.org>,
	Satoru Moriya <satoru.moriya@hds.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"tgraf@infradead.org" <tgraf@infradead.org>,
	"stephen.hemminger@vyatta.com" <stephen.hemminger@vyatta.com>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	Seiji Aguchi <seiji.aguchi@hds.com>, fche@sourceware.org,
	mathieu.desnoyers@polymtl.ca, rostedt@goodmis.org
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:34880 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754756Ab2BFBdL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Feb 2012 20:33:11 -0500
Content-Disposition: inline
In-Reply-To: <20120205200428.GB2816@nuttenaction>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 05, 2012 at 09:04:29PM +0100, Hagen Paul Pfeifer wrote:
> * Neil Horman | 2012-02-05 14:17:08 [-0500]:
> 
> >Generally the fact that probe points may shift underneath a script between
> >kernels.  While its often ok, theres no guaranteed fixed set of probe points.
> >While it often works, theres always the possibility that functional changes,
> >even if they don't reults in behavioral changes to userspace, require re-working
> >of stap scripts.  Its not the sort of thing that works will for people trying to
> >build applications.
> 
> Hey Neil, I though about this more deeply. In my first iteration I had the
> same answer. But IMHO if you think about this more deeply, I think this is not
> a scalable approach (implementing in userspace as systemtap scripts compared
> to implement them in kernelspace (tracepoints). Why? Because at a deep TCP
> level the API (and thus the context) is not static and the meaning of return
> values (or arguments) change over time. No matter _where_ it is implemented or
> coded.
> 
Yes, this is why I'm suggesting alternatives to the tracepoint.

> Lets imaging the following (I construct one example, but this may universal):
> imagine we have two retransmission functions, one for RTO triggered
> retransmission and one for dup-ack fast-retransmission. Both functions where
> instrumented as tracepoints for years. After some years someone say "hey both
> functions are similar, lets fix this and make one function". What should
> happened with the tracepoints? Should they merged into one? What should be the
> name of the tracepoint?
> 
Yes, this is a perenial problem with tracepoints (and, in a simmilar fashion,
stap scripts).

> In the end you will end up fixing userspace analysis tools as well! IMHO there
> is - in my opinion - no clean way to add tracepoints and think you are free of
> maintaining the whole chain, from kernelspace to userspace.
> 
Yes.

> Only "stable" in kernel API's may be a candidate for tracepoints (like kmalloc
> and friends). Highly dynamic and often changed code not.
> 
Yes.

> The biggest advantage from tracepoints is that the function is "annotated"
> with something like "this is a tracepoint, please be nice and don't break the
> behavioral meaning of this function". On the other side this is also a
> disadvantage because it elevates a kernel function to a "userspace API": Tools
> will start using this tracepoint, you may end up in a situation where you
> can't change/delete tracepoints.
> 
Yes, tracepoints only make sense for API's that are clearly stable and well
defined.  This doesn't fit that bill.
 
The long and the short of it is, a tracepoint isn't going to be the solution for
the problem Satoru needs to solve.  Dave just made that abundantly clear.
Another solution needs to be found.  A perf socket layer seems to be a good long
term solution.  If something is needed in the short term for Satoru, I still
think a privately maintained module that registers a netfilter hook to watch
outgoing packets for retransmits offers a good solution.

Regards
Neil

> Hagen
> 
