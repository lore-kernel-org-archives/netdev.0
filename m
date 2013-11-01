From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH net-next RFC 0/5] xen-netback: TX grant mapping instead
 of copy
Date: Fri, 1 Nov 2013 10:50:35 +0000
Message-ID: <1383303035.672.29.camel@kazak.uk.xensource.com>
References: <1383094220-14775-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>, <xen-devel@lists.xenproject.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<jonathan.davies@citrix.com>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1383094220-14775-1-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-10-30 at 00:50 +0000, Zoltan Kiss wrote:
> This patch series use SKBTX_DEV_ZEROCOPY flags to tell the stack it needs to
> know when the skb is freed up.

Does this always avoid copying when bridging/openvswitching/forwarding
(e.g. masquerading etc)? For both domU->domU and domU->physical NIC?

How does it deal with broadcast traffic?

>  That is the way KVM solved the same problem,
> and based on my initial tests it can do the same for us. Avoiding the extra
> copy boosted up TX throughput from 6.8 Gbps to 7.9 (I used a slower
> Interlagos box, both Dom0 and guest on upstream kernel, on the same NUMA node,
> running iperf 2.0.5, and the remote end was a bare metal box on the same 10Gb
> switch)

Do you have any numbers for the dom0 cpu usage impact?

Aggregate throughput for many guests would be a useful datapoint too.

> Based on my investigations the packet get only copied if it is delivered to
> Dom0 stack, which is due to this patch:
> https://lkml.org/lkml/2012/7/20/363
> That's a bit unfortunate, but as far as I know for the huge majority this use
> case is not too important.

Likely to be true, but it would still be interesting to know how badly
this use case suffers with this change, and any increase in CPU usage
would be interesting to know about as well.

>  There are a couple of things which need more
> polishing, see the FIXME comments. I will run some more extensive tests, but
> in the meantime I would like to hear comments about what I've done so far.
> I've tried to broke it down to smaller patches, with mixed results, so I
> welcome suggestions on that part as well:
> 1/5: Introduce TX grant map definitions
> 2/5: Change TX path from grant copy to mapping
> 3/5: Remove old TX grant copy definitons
> 4/5: Fix indentations
> 5/5: Change RX path for mapped SKB fragments
> 
> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
> 
