From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net-next v5 0/9] xen-netback: TX grant mapping with SKBTX_DEV_ZEROCOPY
 instead of copy
Date: Thu, 23 Jan 2014 13:13:07 +0000
Message-ID: <52E11563.1090707@citrix.com>
References: <1390253069-25507-1-git-send-email-zoltan.kiss@citrix.com> <20140122.175031.873909526743971037.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140122.175031.873909526743971037.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 23/01/14 01:50, David Miller wrote:
> From: Zoltan Kiss <zoltan.kiss@citrix.com>
> Date: Mon, 20 Jan 2014 21:24:20 +0000
>
>> A long known problem of the upstream netback implementation that on the TX
>> path (from guest to Dom0) it copies the whole packet from guest memory into
>> Dom0. That simply became a bottleneck with 10Gb NICs, and generally it's a
>> huge perfomance penalty. The classic kernel version of netback used grant
>> mapping, and to get notified when the page can be unmapped, it used page
>> destructors. Unfortunately that destructor is not an upstreamable solution.
>> Ian Campbell's skb fragment destructor patch series [1] tried to solve this
>> problem, however it seems to be very invasive on the network stack's code,
>> and therefore haven't progressed very well.
>> This patch series use SKBTX_DEV_ZEROCOPY flags to tell the stack it needs to
>> know when the skb is freed up.
>
> This series does not apply to net-next due to some other recent changes.
>
> Please respin, thanks.

It is already based on two predecessor patches, one which is already 
accepted but not applied yet:

[PATCH net-next v2] xen-netback: Rework rx_work_todo

And the other one is hopefully will be accepted very soon:

[PATCH v5] xen/grant-table: Avoid m2p_override during mapping

Zoli
