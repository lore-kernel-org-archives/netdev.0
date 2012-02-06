From: "Frank Ch. Eigler" <fche@redhat.com>
Subject: Re: [PATCH v2 0/2] Tracepoint for tcp retransmission
Date: Mon, 6 Feb 2012 10:20:19 -0500
Message-ID: <20120206152019.GG27935@redhat.com>
References: <65795E11DBF1E645A09CEC7EAEE94B9CB728DD67@USINDEVS02.corp.hds.com> <20120120.135028.1359677274445012541.davem@davemloft.net> <65795E11DBF1E645A09CEC7EAEE94B9CB8D3EA7B@USINDEVS02.corp.hds.com> <20120204142823.GA7000@neilslaptop.think-freely.org> <20120204155807.GA2657@nuttenaction> <20120204200937.GA2670@neilslaptop.think-freely.org> <20120205125325.GA31578@elastic.org> <20120205191708.GA5337@neilslaptop.think-freely.org> <20120205200428.GB2816@nuttenaction> <20120206013247.GA5681@neilslaptop.think-freely.org>
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
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59952 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755326Ab2BFPVa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Feb 2012 10:21:30 -0500
Content-Disposition: inline
In-Reply-To: <20120206013247.GA5681@neilslaptop.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Neil -

On Sun, Feb 05, 2012 at 08:32:47PM -0500, Neil Horman wrote:

> [...]
> > Hey Neil, I though about this more deeply. In my first iteration I
> > had the same answer. But IMHO if you think about this more deeply,
> > I think this is not a scalable approach (implementing in userspace
> > as systemtap scripts compared to implement them in kernelspace
> > (tracepoints). Why? Because at a deep TCP level the API (and thus
> > the context) is not static and the meaning of return values (or
> > arguments) change over time. No matter _where_ it is implemented
> > or coded.

> Yes, this is why I'm suggesting alternatives to the tracepoint.

I believe Hagen's point was that alternatives to tracepoints would
have substantially the same difficulty.  At some point in the stack,
you have to standardize/abstract.  What you hook up *at that point* is
not too important: tracepoints, or function calls, or expanded perf
machinery all seem to have the same burden.


> [...] If something is needed in the short term for Satoru, I still
> think a privately maintained module that registers a netfilter hook
> to watch outgoing packets for retransmits offers a good solution.

Does this mean that this netfilter hook mechanism is sufficient to
adapt to the current/future diversity of behaviors?  Why not make
*that* into a tracepoint then, so perf/stap scripts could get at it in
userspace?


- FChE
