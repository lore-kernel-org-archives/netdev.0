From: Julien Grall <julien.grall@citrix.com>
Subject: Re: [Xen-devel] [RFC 21/23] net/xen-netback: Make it running on 64KB
 page granularity
Date: Wed, 20 May 2015 15:29:19 +0100
Message-ID: <555C9A3F.7000207@citrix.com>
References: <1431622863-28575-1-git-send-email-julien.grall@citrix.com>
	<1431622863-28575-22-git-send-email-julien.grall@citrix.com>
	<20150515023534.GE19352@zion.uk.xensource.com>	<5555E81E.8070803@citrix.com>
	<20150515153143.GA8521@zion.uk.xensource.com>	<5559D6EE.3030400@citrix.com>
	<20150518125406.GA9503@zion.uk.xensource.com> <555BBFA7.8030502@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <stefano.stabellini@eu.citrix.com>, <netdev@vger.kernel.org>,
	<tim@xen.org>, <linux-kernel@vger.kernel.org>,
	<xen-devel@lists.xenproject.org>,
	<linux-arm-kernel@lists.infradead.org>,
	Suravee Suthikulpanit <Suravee.Suthikulpanit@amd.com>
To: Julien Grall <julien.grall@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>, <ian.campbell@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <555BBFA7.8030502@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 19/05/15 23:56, Julien Grall wrote:
>> If you're wgetting from another host, I would suggest wgetting from Dom0
>> to limit the problem between Dom0 and DomU.
> 
> Thanks to Wei, I was able to narrow the problem. It looks like the
> problem is not coming from netback but somewhere else down in the
> network stack: wget/ssh between Dom0 64KB and DomU is working fine.
> 
> Although, wget/ssh between a guest and an external host doesn't work
> when Dom0 is using 64KB page granularity unless if I start a tcpdump on
> the vif in DOM0. Anyone an idea?
> 
> I have no issue to wget/ssh in DOM0 to an external host and the same
> kernel with 4KB page granularity (i.e same source code but rebuilt with
> 4KB) doesn't show any issue with wget/ssh in the guest.
> 
> This has been tested on AMD Seattle, the guest kernel is the same on
> every test (4KB page granularity).
> 
> I'm planning to give a try tomorrow on X-gene (ARM64 board and I think
> 64KB page granularity is supported) to see if I can reproduce the bug.

It's working on X-gene with the same kernel and configuration. I guess
we can deduce that it's a bug in the AMD network driver.

Regards,

-- 
Julien Grall
