From: Roland Dreier <rdreier@cisco.com>
Subject: Re: what is the expeted performance from a dual port 10G card ?
Date: Sat, 29 Nov 2008 14:46:08 -0800
Message-ID: <adamyfib173.fsf@cisco.com>
References: <5d96567b0811280511q1e3f7774j7eabce4810dae91a@mail.gmail.com>
	<20081128135419.GH32518@solarflare.com>
	<5d96567b0811290010r641388b7w179bc4af26bbf103@mail.gmail.com>
	<20081129173442.GI32518@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Raz <raziebe@gmail.com>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:36277 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752730AbYK2WqM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Nov 2008 17:46:12 -0500
In-Reply-To: <20081129173442.GI32518@solarflare.com> (Ben Hutchings's message
	of "Sat, 29 Nov 2008 17:34:43 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > The 8b10 encoding is already accounted for in the 2.5 Gbps figure;
 > the raw bit rate is 3.125 Gbps.

No, this is absolutely incorrect for PCI Express.  PCI Express (1.0) raw
signaling is 2.5 gigatransfers/sec, and the overhead of 8b/10b encoding
reduces the data throughput to 2.0 gigabits/sec.  (You may be thinking
of the 10 gigabit ethernet XAUI standard, which uses 8b/10b encoding on
4 lanes running at 3.125 GT/sec to get 10 Gb/sec of data)

In addition, PCI Express transfers are broken up into packets, usually
with very small payloads (128 or 256 bytes are common).  So the packet
header overhead reduces throughput further, and then the transaction
layer adds further overhead.  Then transferring NIC control structures
over the link adds even more overhead.  So achieving 13.something Gb/sec
of real throughput on a PCIe link theoretically capable of 16 Gb/sec
seems pretty good to me.

There are motherboards with PCIe 2.0 slots running at 5.0 GT/sec
available (ie 32 Gb/sec of raw throughput), and I know the Mellanox
ConnectX NIC at least is capable of that as well, so you might be able
to get better performance on such a system.  However, you mention that
most of the NICs top out at 10 Gb/sec in your testing but the Intel NIC
goes higher.  So most likely you are hitting driver limits.  One common
issue is CPU affinity; you might want to play around with setting
interrupt affinity and/or pinning processes to a single CPU.  It might
also be interesting to profile where your CPU time is going.

 - R.
