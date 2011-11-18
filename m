From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next-2.6 PATCH 0/6 v4] macvlan: MAC Address filtering
 support for passthru mode
Date: Fri, 18 Nov 2011 00:15:01 +0000
Message-ID: <1321575301.2749.51.camel@bwh-desktop>
References: <20111109075449.13549.58135.stgit@rhel6.1>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<chrisw@redhat.com>, <sri@us.ibm.com>, <dragos.tatulea@gmail.com>,
	<kvm@vger.kernel.org>, <arnd@arndb.de>, <mst@redhat.com>,
	<gregory.v.rose@intel.com>, <mchan@broadcom.com>,
	<dwang2@cisco.com>, <shemminger@vyatta.com>,
	<eric.dumazet@gmail.com>, <kaber@trash.net>, <benve@cisco.com>
To: Roopa Prabhu <roprabhu@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:28826 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751227Ab1KRAPT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 19:15:19 -0500
In-Reply-To: <20111109075449.13549.58135.stgit@rhel6.1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry to come to this rather late.

On Tue, 2011-11-08 at 23:55 -0800, Roopa Prabhu wrote:
[...]
> v2 -> v3
> - Moved set and get filter ops from rtnl_link_ops to netdev_ops
> - Support for SRIOV VFs.
>         [Note: The get filters msg (in the way current get rtnetlink handles
>         it) might get too big for SRIOV vfs. This patch follows existing sriov 
>         vf get code and tries to accomodate filters for all VF's in a PF. 
>         And for the SRIOV case I have only tested the fact that the VF 
>         arguments are getting delivered to rtnetlink correctly. The code
>         follows existing sriov vf handling code so rest of it should work fine]
[...]

This is already broken for large numbers of VFs, and increasing the
amount of information per VF is going to make the situation worse.  I am
no netlink expert but I think that the current approach of bundling all
information about an interface in a single message may not be
sustainable.

Also, I'm unclear on why this interface is to be used to set filtering
for the (PF) net device as well as for related VFs.  Doesn't that
duplicate the functionality of ndo_set_rx_mode and
ndo_vlan_rx_{add,kill}_vid?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
