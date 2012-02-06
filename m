From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v2 0/2] Tracepoint for tcp retransmission
Date: Mon, 6 Feb 2012 10:53:05 -0500
Message-ID: <20120206155305.GB3620@hmsreliant.think-freely.org>
References: <20120120.135028.1359677274445012541.davem@davemloft.net>
 <65795E11DBF1E645A09CEC7EAEE94B9CB8D3EA7B@USINDEVS02.corp.hds.com>
 <20120204142823.GA7000@neilslaptop.think-freely.org>
 <20120204155807.GA2657@nuttenaction>
 <20120204200937.GA2670@neilslaptop.think-freely.org>
 <20120205125325.GA31578@elastic.org>
 <20120205191708.GA5337@neilslaptop.think-freely.org>
 <20120205200428.GB2816@nuttenaction>
 <20120206013247.GA5681@neilslaptop.think-freely.org>
 <20120206152019.GG27935@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hagen Paul Pfeifer <hagen@jauu.net>,
	"Frank Ch. Eigler" <fche@elastic.org>,
	Satoru Moriya <satoru.moriya@hds.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"tgraf@infradead.org" <tgraf@infradead.org>,
	"stephen.hemminger@vyatta.com" <stephen.hemminger@vyatta.com>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	Seiji Aguchi <seiji.aguchi@hds.com>, fche@sourceware.org,
	mathieu.desnoyers@polymtl.ca, rostedt@goodmis.org
To: "Frank Ch. Eigler" <fche@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:56999 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755298Ab2BFPxU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2012 10:53:20 -0500
Content-Disposition: inline
In-Reply-To: <20120206152019.GG27935@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 06, 2012 at 10:20:19AM -0500, Frank Ch. Eigler wrote:
> Hi, Neil -
> 
> On Sun, Feb 05, 2012 at 08:32:47PM -0500, Neil Horman wrote:
> 
> > [...]
> > > Hey Neil, I though about this more deeply. In my first iteration I
> > > had the same answer. But IMHO if you think about this more deeply,
> > > I think this is not a scalable approach (implementing in userspace
> > > as systemtap scripts compared to implement them in kernelspace
> > > (tracepoints). Why? Because at a deep TCP level the API (and thus
> > > the context) is not static and the meaning of return values (or
> > > arguments) change over time. No matter _where_ it is implemented
> > > or coded.
> 
> > Yes, this is why I'm suggesting alternatives to the tracepoint.
> 
> I believe Hagen's point was that alternatives to tracepoints would
> have substantially the same difficulty.  At some point in the stack,
> you have to standardize/abstract.  What you hook up *at that point* is
> not too important: tracepoints, or function calls, or expanded perf
> machinery all seem to have the same burden.
> 
Yes, that was his point.  Mine was that, given Satoru's needs, a netfilter hook
provides 90% of what they need (as its been described here).  If you're
unfamiliar with them, netfilter hooks are those standard points in the network
input/output/forwarding paths at which we can watch and maniupulate network
traffic.  They're what iptables/ip6tables/ebtables/etc use to do everything they
do.  I'm suggesting that they use those existing hooks to monitor outgoing
traffic for whatever information they want (in this case retransmitted unacked
tcp sequence numbers).  Or whatever else their interested in.

As for the other 10% (recording failed retransmits, which don't generate
traffic), we have existing tracepoints that can be used.

> 
> > [...] If something is needed in the short term for Satoru, I still
> > think a privately maintained module that registers a netfilter hook
> > to watch outgoing packets for retransmits offers a good solution.
> 
> Does this mean that this netfilter hook mechanism is sufficient to
> adapt to the current/future diversity of behaviors?  Why not make
> *that* into a tracepoint then, so perf/stap scripts could get at it in
> userspace?
> 
I suppose you could.  In fact there is a queue target that lets you shuttle
frames from netfilter hook points up to userspace already, so you could do that.
I'm suggesting a kernel module because then you wouldn't have the performance
overhead of moving all those frames to user space.
Neil

> 
> - FChE
> 
