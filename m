From: David Acker <dacker@roinet.com>
Subject: Re: [PATCH] net: expose vlan structure to user space
Date: Fri, 14 Apr 2006 09:15:54 -0400
Message-ID: <443FA08A.8040900@roinet.com>
References: <4436BB69.3010205@roinet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-64-105-159-118.phlapafg.covad.net ([64.105.159.118]:58806
	"HELO roinet.com") by vger.kernel.org with SMTP id S1751250AbWDNNPz
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Apr 2006 09:15:55 -0400
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <4436BB69.3010205@roinet.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Acker wrote:
>  From Dave Acker <dacker@roinet.com>
> 
> The purpose is to allow a user space program to use the vlan_ethhdr
> structure when directly handling 802.1Q packets.  This can be done
> by using a raw socket like:
> int s = socket(PF_PACKET, SOCK_RAW, htons(ETH_P_ALL));
> This socket should see VLAN packets from the base interface unchanged
> (i.e. vlan tag still in packet).
> Currently other user space programs that understand VLANs seem to all
> create their own definitions for this structure.
> This patch does NOT expose the defines related to the sizes of VLAN 
> packets and
> their fields; it only exposes the vlan_ethhdr structure.  It was determined
> that these sizes are not useful since the packet could be as large the MTU
> of the underlying physical network.  Also, you can have nested VLAN headers
> such that the actual data offset is greater than the size of the 
> vlan_ethhdr
> structure.
> -Dave Acker
> 

Hello folks.  Although some conversation appeared on earlier postings of 
this patch, I though I would reply here since the post I am replying to 
here gets the diff format right (from the top level instead of deep in 
the source).  Last I heard:

David S. Miller wrote:
 > I think this really belongs in a portable header file
 > in glibc somewhere.

David, while I can try to work with the glibc folks, I don't understand 
how this patch would be different from what if_ether.h exposes to user 
space today.  Why is one appropriate and the other not?  I am not trying 
to be a pain; I am just trying to understand the rationale so that I can 
explain it to others.

Thanks,
Dave Acker
