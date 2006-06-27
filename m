From: Herbert Poetzl <herbert@13thfloor.at>
Subject: Re: [patch 2/6] [Network namespace] Network device sharing by view
Date: Wed, 28 Jun 2006 00:48:37 +0200
Message-ID: <20060627224836.GA2612@MAIL.13thfloor.at>
References: <449FF5A0.2000403@fr.ibm.com> <20060626192751.A989@castle.nmd.msu.ru> <44A00215.2040608@fr.ibm.com> <m1hd27uaxw.fsf@ebiederm.dsl.xmission.com> <20060626183649.GB3368@MAIL.13thfloor.at> <m1u067r9qk.fsf@ebiederm.dsl.xmission.com> <44A05BFD.6030402@candelatech.com> <20060626225440.GA7425@MAIL.13thfloor.at> <44A068E7.6080403@candelatech.com> <44A157CA.70204@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Andrey Savochkin <saw@swsoft.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	serue@us.ibm.com, haveblue@us.ibm.com, clg@fr.ibm.com,
	Andrew Morton <akpm@osdl.org>, dev@sw.ru, devel@openvz.org,
	sam@vilain.net, viro@ftp.linux.org.uk,
	Alexey Kuznetsov <alexey@sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MAIL.13thfloor.at ([212.16.62.50]:24798 "EHLO mail.13thfloor.at")
	by vger.kernel.org with ESMTP id S1422703AbWF0Wsi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2006 18:48:38 -0400
To: Ben Greear <greearb@candelatech.com>
Content-Disposition: inline
In-Reply-To: <44A157CA.70204@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 27, 2006 at 09:07:38AM -0700, Ben Greear wrote:
> Ben Greear wrote:
> >Herbert Poetzl wrote:
> >
> >>On Mon, Jun 26, 2006 at 03:13:17PM -0700, Ben Greear wrote:
> >
> >>yes, that sounds good to me, any numbers how that
> >>affects networking in general (performance wise and
> >>memory wise, i.e. caches and hashes) ...
> >
> >I'll run some tests later today.  Based on my previous tests,
> >I don't remember any significant overhead.
> 
> Here's a quick benchmark using my redirect devices (RDD). Each RDD
> comes in a pair...when you tx on one, the pkt is rx'd on the peer.
> The idea is that it is exactly like two physical ethernet interfaces
> connected by a cross-over cable.
>
> My test system is a 64-bit dual-core Intel system, 3.013 Ghz processor
> with 1GB RAM. Fairly standard stuff..it's one of the Shuttle XPC
> systems. Kernel is 2.6.16.16 (64-bit).
> 
> 
> Test setup is:  rdd1 -- rdd2   [bridge]   rdd3 -- rdd4
> 
> I am using my proprietary module for the bridge logic...and the
> default bridge should be at least this fast. I am injecting 1514 byte
> packets on rdd1 and rdd4 with pktgen (bi-directional flow). My pktgen
> is also receiving the pkts and gathering stats.
>
> This setup sustains 1.7Gbps of generated and received traffic between
> rdd1 and rdd4.
>
> Running only the [bridge] between two 10/100/1000 ports on an Intel
> PCI-E NIC will sustain about 870Mbps (bi-directional) on this system,
> so the virtual devices are quite efficient, as suspected.
>
> I have not yet had time to benchmark the mac-vlans...hopefully later
> today.

hmm, maybe you could also benchmark loopback connections
(and their throughput) on your system?

my (not so fancy) PIII, 32bit, 2.6.17.1 seems to do
roughly 2Gbs on the loopback device (tested with dd
and netcat)

best,
Herbert

> Thanks,
> Ben
> 
> -- 
> Ben Greear <greearb@candelatech.com>
> Candela Technologies Inc  http://www.candelatech.com
