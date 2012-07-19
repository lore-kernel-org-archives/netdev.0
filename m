From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next V1 7/9] net/eipoib: Add main driver
 functionality
Date: Thu, 19 Jul 2012 17:16:14 +0100
Message-ID: <1342714574.2617.43.camel@bwh-desktop.uk.solarflarecom.com>
References: <1342609202-32427-1-git-send-email-ogerlitz@mellanox.com>
	  <1342609202-32427-8-git-send-email-ogerlitz@mellanox.com>
	 <1342705789.2617.15.camel@bwh-desktop.uk.solarflarecom.com>
	 <50082BDE.2040005@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <roland@kernel.org>,
	<netdev@vger.kernel.org>, <ali@mellanox.com>,
	<sean.hefty@intel.com>, <shlomop@mellanox.com>,
	Erez Shitrit <erezsh@mellanox.co.il>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:22404 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750894Ab2GSQQT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 12:16:19 -0400
In-Reply-To: <50082BDE.2040005@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-07-19 at 18:46 +0300, Or Gerlitz wrote:
> On 7/19/2012 4:49 PM, Ben Hutchings wrote:
> > On Wed, 2012-07-18 at 14:00 +0300, Or Gerlitz wrote:
[...]
> >> +	.ndo_vlan_rx_add_vid = eth_ipoib_vlan_rx_add_vid,
> >> +	.ndo_vlan_rx_kill_vid = eth_ipoib_vlan_rx_kill_vid,
> >
> > These shouldn't be needed.
> 
> ok, here's the point, the eIPoIB driver maps Ethernet vlans to 
> infiniband/IPoIB pkeys
> (partition keys). The underlying IPoIB devices work with these pkeys
> in a way which is HW accelerated, and we want the eIPoIB driver to be 
> considered as one
> that support HW accelerate vlans. E.g on the TX flow we don't want that 
> any special SW
> handling by the 8021q driver will be done on the skb except for setting 
> the skb->vlan_tci
> field, and in the RX flow, we set skb->vlan_tci field and don't want 
> that 8021q to try
> and extract it from the headers, etc.
> 
> For that end, I was under the impression all the three 
> NETIF_F_HW_VLAN_{TX,RX,FILTER)
> features need to be advertized. From your comment I understand now that 
> RX/TX are enough
> in that respect?
[...]

Yes.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
