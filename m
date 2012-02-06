From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 0/2] Tracepoint for tcp retransmission
Date: Mon, 06 Feb 2012 18:02:34 +0100
Message-ID: <1328547754.2220.86.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
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
	 <1328545089.2200.13.camel@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neil Horman <nhorman@tuxdriver.com>,
	"Frank Ch. Eigler" <fche@redhat.com>,
	Hagen Paul Pfeifer <hagen@jauu.net>,
	"Frank Ch. Eigler" <fche@elastic.org>,
	Satoru Moriya <satoru.moriya@hds.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"tgraf@infradead.org" <tgraf@infradead.org>,
	"stephen.hemminger@vyatta.com" <stephen.hemminger@vyatta.com>,
	Seiji Aguchi <seiji.aguchi@hds.com>, fche@sourceware.org,
	mathieu.desnoyers@polymtl.ca
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:56021 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755513Ab2BFRCi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2012 12:02:38 -0500
Received: by wgbdt10 with SMTP id dt10so6429231wgb.1
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2012 09:02:37 -0800 (PST)
In-Reply-To: <1328545089.2200.13.camel@gandalf.stny.rr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 06 f=C3=A9vrier 2012 =C3=A0 11:18 -0500, Steven Rostedt a =C3=A9=
crit :
> On Mon, 2012-02-06 at 10:53 -0500, Neil Horman wrote:
>=20
> > Yes, that was his point.  Mine was that, given Satoru's needs, a ne=
tfilter hook
> > provides 90% of what they need (as its been described here).  If yo=
u're
> > unfamiliar with them, netfilter hooks are those standard points in =
the network
> > input/output/forwarding paths at which we can watch and maniupulate=
 network
> > traffic.  They're what iptables/ip6tables/ebtables/etc use to do ev=
erything they
> > do.  I'm suggesting that they use those existing hooks to monitor o=
utgoing
> > traffic for whatever information they want (in this case retransmit=
ted unacked
> > tcp sequence numbers).  Or whatever else their interested in.
> >=20
> > As for the other 10% (recording failed retransmits, which don't gen=
erate
> > traffic), we have existing tracepoints that can be used.
>=20
> I haven't looked at the details here, but I'm wondering if netfilter
> could benefit from static_branch() calls (aka jump-labels). I'm sure
> selinux could too. Basically, when netfilter is disabled, the fast pa=
th
> would just include a nop, with no if() branch testing at all. When yo=
u
> enable netfilters, it would then add a jmp to the code that actually
> does the tests.

Hmm... I thought I already did that.

Or maybe I intended so and forgot.

Ah no, its there in commit a2d7ec58ac09
(netfilter: use jump_label for nf_hooks)
