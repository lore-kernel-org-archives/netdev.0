From: Ben Greear <greearb@candelatech.com>
Subject: Re: [RFC] Enable/Disable VLAN HW filters
Date: Thu, 31 Aug 2006 16:40:52 -0700
Message-ID: <44F77384.4030707@candelatech.com>
References: <1157064667.4416.14.camel@strongmad>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:49381 "EHLO ns2.lanforge.com")
	by vger.kernel.org with ESMTP id S932300AbWHaXj6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2006 19:39:58 -0400
To: Mitch Williams <mitch.a.williams@intel.com>
In-Reply-To: <1157064667.4416.14.camel@strongmad>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mitch Williams wrote:
> We've had a few internal requests for a way to enable and disable the
> hardware VLAN filter at runtime.  I'm posting it here for discussion and
> to see if anybody else is interested in this feature.
> 
> Originally I had planned to do this as an Ethtool ioctl, but decided
> instead to handle it through the VLAN module.  Ethtool doesn't know
> anything about VLANs at all.
> 
> There are no userspace changes required to support this functionality.
> 
> To disable HW VLAN filtering:
> # vconfig set_flag <VLAN interface> 2 1
> 
> To enable HW VLAN filtering:
> # vconfig set_flag <VLAN interface> 2 0
> 
> At this point (somewhat obviously), it's only implemented on e1000, but
> this ioctl could be easily implemented by other drivers.

Sounds like a good idea to me.

> +	switch (flag) {
> +	case VLAN_FLAG_REORDER:
> +		if (flag_val)
> +			VLAN_DEV_INFO(dev)->flags |= 1;
> +		else
> +			VLAN_DEV_INFO(dev)->flags &= ~1;
> +		break;

If we're defining constants for the flags, might as well use them here 
instead of using the bare '1'.

Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

