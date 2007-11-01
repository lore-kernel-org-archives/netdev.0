From: Ben Greear <greearb@candelatech.com>
Subject: Re: expected behavior of PF_PACKET on NETIF_F_HW_VLAN_RX device?
Date: Wed, 31 Oct 2007 18:31:10 -0700
Message-ID: <47292C5E.4050709@candelatech.com>
References: <18216.52455.698606.497464@zeus.sw.starentnetworks.com> <20071031123359.3954befc@freepuppy.rosehill> <4729269A.6090606@candelatech.com> <47292A99.5070805@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dave Johnson <djohnson+linux-kernel@sw.starentnetworks.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Bin Guo <bguo@sw.starentnetworks.com>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:48638 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752454AbXKABbQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Oct 2007 21:31:16 -0400
In-Reply-To: <47292A99.5070805@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
>
> The code in AF_PACKET should fix the skb before passing to user space 
> so that there is
> no difference between accel and non-accel hardware.  Internal choices 
> shouldn't
> leak to user space.  Ditto, the receive checksum offload should be 
> fixed up as well.
Ok, I guess that will fix the sniffing issues and any user-space 
bridging type applications.

Currently, VLAN devices offer the ability to 'reorder' the header and 
explicitly remove the VLAN
header.  I assume we keep this feature and have the AF_PACKET logic 
check the device
flags to see if it should insert the VLAN header for hw-accel vlans?

Either way, if we sniff the underlying device, we should always get the 
VLAN header.

What about drivers and filtering VLANs?  It seems there is still a 
difference between software
vlans and hw-accel in this case.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


