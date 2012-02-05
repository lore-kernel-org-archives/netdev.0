From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v2 0/2] Tracepoint for tcp retransmission
Date: Sun, 5 Feb 2012 14:17:08 -0500
Message-ID: <20120205191708.GA5337@neilslaptop.think-freely.org>
References: <65795E11DBF1E645A09CEC7EAEE94B9CB728DD67@USINDEVS02.corp.hds.com>
 <20120120.135028.1359677274445012541.davem@davemloft.net>
 <65795E11DBF1E645A09CEC7EAEE94B9CB8D3EA7B@USINDEVS02.corp.hds.com>
 <20120204142823.GA7000@neilslaptop.think-freely.org>
 <20120204155807.GA2657@nuttenaction>
 <20120204200937.GA2670@neilslaptop.think-freely.org>
 <20120205125325.GA31578@elastic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hagen Paul Pfeifer <hagen@jauu.net>,
	Satoru Moriya <satoru.moriya@hds.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"tgraf@infradead.org" <tgraf@infradead.org>,
	"stephen.hemminger@vyatta.com" <stephen.hemminger@vyatta.com>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	Seiji Aguchi <seiji.aguchi@hds.com>, fche@sourceware.org
To: "Frank Ch. Eigler" <fche@elastic.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:54315 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755144Ab2BETRe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Feb 2012 14:17:34 -0500
Content-Disposition: inline
In-Reply-To: <20120205125325.GA31578@elastic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 05, 2012 at 07:53:25AM -0500, Frank Ch. Eigler wrote:
> Hi -
> 
> On Sat, Feb 04, 2012 at 03:09:37PM -0500, Neil Horman wrote:
> > [...]
> 
> > Systemtap is fine for development.  Lots of application/product
> > vendors really don't like it.  On top of the difficult to use
> > aspect
> 
> (Just curious, what difficulty-to-use aspect have you more recently
> come across?)
> 
Generally the fact that probe points may shift underneath a script between
kernels.  While its often ok, theres no guaranteed fixed set of probe points.
While it often works, theres always the possibility that functional changes,
even if they don't reults in behavioral changes to userspace, require re-working
of stap scripts.  Its not the sort of thing that works will for people trying to
build applications.

> > it requires that debugging stabs info be kept with the kernel, which
> > is a real pain, especially if you're running on a stable kernel.
> > [...]
> 
> You probably mean when running on an unstable kernel, no?  Installing
> debuginfo for a stable kernel is a one-time event.  It also enables
No its a one time-per kernel event.  Unless you plan on never updating your
kernel, you still have to install the corresponding debuginfo with each kernel
that you update to.

> "perf probe" and crash(8) and other tools.  Plus, with systemtap,
> there are two separate network-remoting mechanisms (--use-server
> compilation and --remote execution) that make local debuginfo
> unnecessary.
> 
Yes, but as I noted above, these are development and problem determination
tools, things that either a developer will use or a sysadmin will install on
demand when trying to diagnose a problem in the system.  People balk when buying
an application and find out that to run it requires the addition of a few Gigs
of debuginfo information, even if it enables other tools too.

> Anyway, a reasonable way to go may be to prototype in stap whatever
> hard-coded kernel module y'all envision finally doing this work.
> 
Absolutely, and from what I understand this is what Satoru has already done.
Their flight recorder does tcp retransmit stat counting using systemtap
currently, and he's now looking to codify the feature as they currently have it
using a slightly more stable API.  The tracepoint has been balked at, so I was
suggesting using netfilter as an alternate solution

Neil

> - FChE
> 
