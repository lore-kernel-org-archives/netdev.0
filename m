From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Wed, 1 Apr 2009 16:38:44 +1030
Message-ID: <200904011638.45135.rusty@rustcorp.com.au>
References: <20090331184057.28333.77287.stgit@dev.haskins.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, anthony@codemonkey.ws,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: Gregory Haskins <ghaskins@novell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:58925 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752877AbZDAGJB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Apr 2009 02:09:01 -0400
In-Reply-To: <20090331184057.28333.77287.stgit@dev.haskins.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 01 April 2009 05:12:47 Gregory Haskins wrote:
> Bare metal: tput = 4078Mb/s, round-trip = 25593pps (39us rtt)
> Virtio-net: tput = 4003Mb/s, round-trip = 320pps (3125us rtt)
> Venet: tput = 4050Mb/s, round-trip = 15255 (65us rtt)

That rtt time is awful.  I know the notification suppression heuristic
in qemu sucks.

I could dig through the code, but I'll ask directly: what heuristic do
you use for notification prevention in your venet_tap driver?

As you point out, 350-450 is possible, which is still bad, and it's at least
partially caused by the exit to userspace and two system calls.  If virtio_net
had a backend in the kernel, we'd be able to compare numbers properly.

> Bare metal: tput = 9717Mb/s, round-trip = 30396pps (33us rtt)
> Virtio-net: tput = 4578Mb/s, round-trip = 249pps (4016us rtt)
> Venet: tput = 5802Mb/s, round-trip = 15127 (66us rtt)
> 
> Note that even the throughput was slightly better in this test for venet, though
> neither venet nor virtio-net could achieve line-rate.  I suspect some tuning may
> allow these numbers to improve, TBD.

At some point, the copying will hurt you.  This is fairly easy to avoid on
xmit tho.

Cheers,
Rusty.
