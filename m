From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] bonding: send IPv6 neighbor advertisement on failover
Date: Wed, 8 Oct 2008 18:26:34 +1100
Message-ID: <20081008072632.GL22396@verge.net.au>
References: <48EC091D.7080207@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	David Miller <davem@davemloft.net>,
	Vladislav Yasevich <vladislav.yasevich@hp.com>,
	Alex Sidorenko <alexandre.sidorenko@hp.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:46694 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754665AbYJHH0g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 03:26:36 -0400
Content-Disposition: inline
In-Reply-To: <48EC091D.7080207@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 07, 2008 at 09:13:01PM -0400, Brian Haley wrote:
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
> behavior when in active-back mode, I saw no lost ping packets for 
> example.
>
> -Brian
>
> Signed-off-by: Brian Haley <brian.haley@hp.com>

The Kconfig / build portions of this look fine to me.


-- 
Simon Horman
  VA Linux Systems Japan K.K., Sydney, Australia Satellite Office
  H: www.vergenet.net/~horms/             W: www.valinux.co.jp/en

