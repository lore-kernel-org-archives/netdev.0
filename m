From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH v2] bonding: send IPv6 neighbor advertisement on failover
Date: Mon, 27 Oct 2008 16:07:35 -0400
Message-ID: <49061F87.2090409@hp.com>
References: <48EEA752.6030505@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Simon Horman <horms@verge.net.au>,
	Alex Sidorenko <alexandre.sidorenko@hp.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:6258 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752708AbYJ0UHj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2008 16:07:39 -0400
In-Reply-To: <48EEA752.6030505@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jay,

Did you ever get a chance to look at this patch?  Now that net-next is 
open I'd like to resubmit it.

Thanks,

-Brian

Brian Haley wrote:
> Updated to address Vlad's comment about storing the link-local IPv6 
> address in the bond/vlan structure, I no longer overwrite the existing 
> address with a newer one.  Also added missed locking for the inet6_dev.
> 
> I don't see any way to address David Steven's comment since there is 
> currently no NA tunable in the IPv6 code.
> 
> ---
> 
> This patch adds better IPv6 failover support for bonding devices,
> especially when in active-backup mode and there are only IPv6 addresses
> configured, as reported by Alex Sidorenko.
> 
> - Creates a new file, net/drivers/bonding/bond_ipv6.c, for the
>   IPv6-specific routines.  Both regular bonds and VLANs over bonds
>   are supported.
> 
> - Adds a new tunable, num_unsol_na, to limit the number of unsolicited
>   IPv6 Neighbor Advertisements that are sent on a failover event.
>   Default is 1.
> 
> - Creates two new IPv6 neighbor discovery functions:
> 
>   ndisc_build_skb()
>   ndisc_send_skb()
> 
>   These were required to support VLANs since we have to be able to
>   add the VLAN id to the skb since ndisc_send_na() and friends
>   shouldn't be asked to do this.  These two routines are basically
>   __ndisc_send() split into two pieces, in a slightly different order.
> 
> - Updates Documentation/networking/bonding.txt and bumps the rev of bond
>   support to 3.4.0.
> 
> On failover, this new code will generate one packet:
> 
> - An unsolicited IPv6 Neighbor Advertisement, which helps the switch
>   learn that the address has moved to the new slave.
> 
> Testing has shown that sending just the NA results in pretty good
> behavior when in active-back mode, I saw no lost ping packets for example.
> 
> -Brian
> 
> Signed-off-by: Brian Haley <brian.haley@hp.com>
> ---
> 
