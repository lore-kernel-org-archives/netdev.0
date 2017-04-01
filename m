From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: Re: [PATCH net-next 1/1 v2] net: rmnet_data: Initial implementation
Date: Fri, 31 Mar 2017 23:43:31 -0600
Message-ID: <59f9a5da83d995c8a572b44c9b248ae2@codeaurora.org>
References: <1489390989-2408-1-git-send-email-subashab@codeaurora.org>
 <1489390989-2408-2-git-send-email-subashab@codeaurora.org>
 <1490394075.3227.9.camel@redhat.com>
 <4bd7c38e551505fa8d035d5e1b209d8e@codeaurora.org>
 <1491000080.13807.1.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        fengguang.wu@intel.com, netdev-owner@vger.kernel.org
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:35268 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750796AbdDAFnd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Apr 2017 01:43:33 -0400
In-Reply-To: <1491000080.13807.1.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Yeah, seems quite a bit like VLAN (from a workflow perspective, not
> quite as much from a protocol one) and I think the same workflow could
> work for this too.  Would be nice to eventually get qmi_wwan onto the
> same base, if possible (though we'd need to preserve the 802.3
> capability somehow for devices that don't support raw-ip).
> 
> It doesn't necessarily mean that configuration would need to move to
> the IP tool.  I just used it as an example of how VLAN works and how
> rmnet could work as well, quite easily with the ip tool.
> 
> Since the ip tool is based on netlink, both it and your userspace
> library could use the same netlink attributes and families to do the
> same thing.
> 
> Essentially, I am recommending that instead of your current custom
> netlink commands, port them over to rtnetlink which will mean less code
> for you, and a more standard kernel interface for everyone.
> 
Thanks for your comments. I'll work on conversion into rtnl_link_ops.

Ethernet frames are supported in pass through mode (though not used 
often)
but they cannot be used in conjunction with MAP functionality.

> Does the aggregation happen at the level of the raw device, or at the
> level of the MUX channels?  eg, can I aggregate packets from multiple
> MUX channels into the same request, especially on USB devices?
> 
Hardware does allow aggregation of packets from different mux channels 
in
a single frame.

> One use-case is to put different packet data contexts into different
> namespaces.  You could then isolate different EPS/PDP contexts by
> putting them into different network namespaces, and for example have
> your IMS handler only be able to access its own EPS/PDP context.
> 
> We could already do this with qmi_wwan on devices that provide multiple
> USB endpoints for QMI/rmnet, but I thought the point of the MUX
> protocol was to allow a single endpoint for rmnet that can MUX multiple
> packet data contexts.  So it would be nice to allow each rmnet netdev
> to be placed into a different network namespace.
> 
I need to study more about namespaces since I am not familiar with it.
I'll add support for it in a follow up patchset.

> Like a usb gadget rmnet interface for debugging?
> 
Yes, its mostly used for test only.
