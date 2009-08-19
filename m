From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model for
	vbus_driver objects
Date: Wed, 19 Aug 2009 17:33:39 +0300
Message-ID: <20090819143339.GB3862@redhat.com>
References: <20090814154308.26116.46980.stgit@dev.haskins.net> <20090815103243.GA26749@elte.hu> <4A870964.9090408@codemonkey.ws> <4A8965E0.8050608@gmail.com> <4A89FF08.30509@codemonkey.ws> <4A8AA9BD.2070909@gmail.com> <4A8AB076.6080906@redhat.com> <4A8ACE1F.6020402@gmail.com> <20090818165139.GC19846@redhat.com> <4A8B8F4E.80207@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Avi Kivity <avi@redhat.com>,
	Anthony Liguori <anthony@codemonkey.ws>,
	Ingo Molnar <mingo@elte.hu>,
	Gregory Haskins <ghaskins@novell.com>, kvm@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Gregory Haskins <gregory.haskins@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:58887 "EHLO mx2.redhat.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751870AbZHSOfb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Aug 2009 10:35:31 -0400
Content-Disposition: inline
In-Reply-To: <4A8B8F4E.80207@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 19, 2009 at 01:36:14AM -0400, Gregory Haskins wrote:
> Please post results when you have numbers, as I had to
> give up my 10GE rig in the lab.
> I suspect you will have performance
> issues until you at least address GSO, but you may already be there by now.

Yes, measuring streaming bandwidth probably does not make sense yet, as
I do not have GSO, and I do not have VM exit mitigation. But RSN.

Meanwhile udp_rr does not need any of these, so I checked that and numbers look
like what you'd expect.  My systems seem slower than yours, but the
virtualization overhead is same: around 20us (sometimes it's a bit higher, up
to 25us).

host to host:

[root@virtlab18 netperf-2.4.5]# ~mst/netperf-2.4.5/bin/netperf -H 20.1.50.1 -t
+udp_rr
UDP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 20.1.50.1
+(20.1.50.1) port 0 AF_INET
Local /Remote
Socket Size   Request  Resp.   Elapsed  Trans.
Send   Recv   Size     Size    Time     Rate
bytes  Bytes  bytes    bytes   secs.    per sec

262144 262144 1        1       10.00    13890.41
124928 124928

host to guest:

[root@virtlab18 linux-2.6]# ~mst/netperf-2.4.5/bin/netperf -H 20.1.50.3 -t udp_rr
UDP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 20.1.50.3
+(20.1.50.3) port 0 AF_INET
Local /Remote
Socket Size   Request  Resp.   Elapsed  Trans.
Send   Recv   Size     Size    Time     Rate
bytes  Bytes  bytes    bytes   secs.    per sec

262144 262144 1        1       10.00    10884.78
124928 124928


-- 
MST
