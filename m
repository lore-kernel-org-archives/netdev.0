From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v2 0/2] Tracepoint for tcp retransmission
Date: Mon, 06 Feb 2012 11:18:09 -0500
Message-ID: <1328545089.2200.13.camel@gandalf.stny.rr.com>
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
	 <20120206155305.GB3620@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Cc: "Frank Ch. Eigler" <fche@redhat.com>,
	Hagen Paul Pfeifer <hagen@jauu.net>,
	"Frank Ch. Eigler" <fche@elastic.org>,
	Satoru Moriya <satoru.moriya@hds.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"tgraf@infradead.org" <tgraf@infradead.org>,
	"stephen.hemminger@vyatta.com" <stephen.hemminger@vyatta.com>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	Seiji Aguchi <seiji.aguchi@hds.com>, fche@sourceware.org,
	mathieu.desnoyers@polymtl.ca
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hrndva-omtalb.mail.rr.com ([71.74.56.123]:59693 "EHLO
	hrndva-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755247Ab2BFQSQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2012 11:18:16 -0500
In-Reply-To: <20120206155305.GB3620@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-02-06 at 10:53 -0500, Neil Horman wrote:

> Yes, that was his point.  Mine was that, given Satoru's needs, a netfilter hook
> provides 90% of what they need (as its been described here).  If you're
> unfamiliar with them, netfilter hooks are those standard points in the network
> input/output/forwarding paths at which we can watch and maniupulate network
> traffic.  They're what iptables/ip6tables/ebtables/etc use to do everything they
> do.  I'm suggesting that they use those existing hooks to monitor outgoing
> traffic for whatever information they want (in this case retransmitted unacked
> tcp sequence numbers).  Or whatever else their interested in.
> 
> As for the other 10% (recording failed retransmits, which don't generate
> traffic), we have existing tracepoints that can be used.

I haven't looked at the details here, but I'm wondering if netfilter
could benefit from static_branch() calls (aka jump-labels). I'm sure
selinux could too. Basically, when netfilter is disabled, the fast path
would just include a nop, with no if() branch testing at all. When you
enable netfilters, it would then add a jmp to the code that actually
does the tests.

-- Steve
