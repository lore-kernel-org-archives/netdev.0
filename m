From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [Xen-devel] [PATCH net-next v2 0/9] xen-netback: TX grant mapping
 with SKBTX_DEV_ZEROCOPY instead of copy
Date: Mon, 16 Dec 2013 16:13:44 +0000
Message-ID: <52AF26B8.2090409@citrix.com>
References: <1386892097-15502-1-git-send-email-zoltan.kiss@citrix.com> <52AE9E7E.7040502@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>
To: annie li <annie.li@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52AE9E7E.7040502@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 16/12/13 06:32, annie li wrote:
>
> On 2013/12/13 7:48, Zoltan Kiss wrote:
>> A long known problem of the upstream netback implementation that on
>> the TX
>> path (from guest to Dom0) it copies the whole packet from guest memory
>> into
>> Dom0. That simply became a bottleneck with 10Gb NICs, and generally
>> it's a
>> huge perfomance penalty. The classic kernel version of netback used grant
>> mapping, and to get notified when the page can be unmapped, it used page
>> destructors. Unfortunately that destructor is not an upstreamable
>> solution.
>> Ian Campbell's skb fragment destructor patch series [1] tried to solve
>> this
>> problem, however it seems to be very invasive on the network stack's
>> code,
>> and therefore haven't progressed very well.
>> This patch series use SKBTX_DEV_ZEROCOPY flags to tell the stack it
>> needs to
>> know when the skb is freed up. That is the way KVM solved the same
>> problem,
>> and based on my initial tests it can do the same for us. Avoiding the
>> extra
>> copy boosted up TX throughput from 6.8 Gbps to 7.9 (I used a slower
>> Interlagos box, both Dom0 and guest on upstream kernel, on the same
>> NUMA node,
>> running iperf 2.0.5, and the remote end was a bare metal box on the
>> same 10Gb
>> switch)
> Sounds good.
> Is the TX throughput gotten between one vm and one bare metal box? or
> between multiple vms and bare metal? Do you have any test results with
> netperf?
One VM and a bare metal box. I've used only iperf.

Regards,

Zoli
