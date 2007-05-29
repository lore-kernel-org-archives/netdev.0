From: Patrick McHardy <kaber@trash.net>
Subject: Re: [SKY2]: Fix VLAN unregistration
Date: Tue, 29 May 2007 12:57:31 +0200
Message-ID: <465C071B.5080109@trash.net>
References: <4659D174.70301@trash.net> <465B4CCC.7020002@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37582 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756172AbXE2K5q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 May 2007 06:57:46 -0400
In-Reply-To: <465B4CCC.7020002@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Greear wrote:
> Patrick McHardy wrote:
> 
>> Fix sky2 disabling VLAN completely when the first vid is unregistered.
>>
>> For some reason the VLAN code insists on the driver providing a
>> vlan_rx_kill_vid function even if only NETIF_F_HW_VLAN_RX and not
>> NETIF_F_HW_VLAN_FILTER is set, so this patch keeps an empty
>> function. This seems to be a bug though, vlan_rx_add_vid is only
>> required with NETIF_F_HW_VLAN_FILTER. Ben?
>>   
> 
> I believe DaveM did most of the vlan hw-accel work.  It would be easy
> enough to check
> for a null function before calling the vlan_rx_kill_vid function and
> relax the checks
> based on the flags, but there may be valid reasons to keep this as is. 


Most drivers are using vlan_rx_kill_vid to remove a vid from the
group under their local local lock, which seems unnecessary since
the VLAN code calls synchronize_net before freeing it and also
does the removal itself. A few others have empty functions and
8139cp seems to have the same bug as sky2. In all cases it doesn't
seem to be needed for drivers without NETIF_F_HW_VLAN_FILTER.


