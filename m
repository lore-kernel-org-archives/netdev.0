From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH net-next v5 0/9] xen-netback: TX grant mapping with
 SKBTX_DEV_ZEROCOPY instead of copy
Date: Wed, 19 Feb 2014 09:50:34 +0000
Message-ID: <1392803434.23084.97.camel@kazak.uk.xensource.com>
References: <1390253069-25507-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>, <xen-devel@lists.xenproject.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<jonathan.davies@citrix.com>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1390253069-25507-1-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-01-20 at 21:24 +0000, Zoltan Kiss wrote:
> A long known problem of the upstream netback implementation that on the TX
> path (from guest to Dom0) it copies the whole packet from guest memory into
> Dom0. That simply became a bottleneck with 10Gb NICs, and generally it's a
> huge perfomance penalty. The classic kernel version of netback used grant
> mapping, and to get notified when the page can be unmapped, it used page
> destructors. Unfortunately that destructor is not an upstreamable solution.
> Ian Campbell's skb fragment destructor patch series [1] tried to solve this
> problem, however it seems to be very invasive on the network stack's code,
> and therefore haven't progressed very well.
> This patch series use SKBTX_DEV_ZEROCOPY flags to tell the stack it needs to
> know when the skb is freed up. That is the way KVM solved the same problem,
> and based on my initial tests it can do the same for us. Avoiding the extra
> copy boosted up TX throughput from 6.8 Gbps to 7.9 (I used a slower
> Interlagos box, both Dom0 and guest on upstream kernel, on the same NUMA node,
> running iperf 2.0.5, and the remote end was a bare metal box on the same 10Gb
> switch)
> Based on my investigations the packet get only copied if it is delivered to
> Dom0 stack,

This is not quite complete/accurate since you previously told me that it
is copied in the NAT/routed rather than bridged network topologies.

Please can you cover that aspect here too.

Ian.
