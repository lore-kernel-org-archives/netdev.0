From: Ben Greear <greearb@candelatech.com>
Subject: Re: [SKY2]: Fix VLAN unregistration
Date: Mon, 28 May 2007 14:42:36 -0700
Message-ID: <465B4CCC.7020002@candelatech.com>
References: <4659D174.70301@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:35902 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750963AbXE1Vmm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 May 2007 17:42:42 -0400
In-Reply-To: <4659D174.70301@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Fix sky2 disabling VLAN completely when the first vid is unregistered.
>
> For some reason the VLAN code insists on the driver providing a
> vlan_rx_kill_vid function even if only NETIF_F_HW_VLAN_RX and not
> NETIF_F_HW_VLAN_FILTER is set, so this patch keeps an empty
> function. This seems to be a bug though, vlan_rx_add_vid is only
> required with NETIF_F_HW_VLAN_FILTER. Ben?
>   
I believe DaveM did most of the vlan hw-accel work.  It would be easy 
enough to check
for a null function before calling the vlan_rx_kill_vid function and 
relax the checks
based on the flags, but there may be valid reasons to keep this as is.  
Perhaps
DaveM will comment...

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


