From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [RFC, VLAN]: Propagate selected feature bits to VLAN devices
Date: Tue, 20 May 2008 12:58:28 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC329051AC9FE@orsmsx414.amr.corp.intel.com>
References: <4832E223.7020206@trash.net> <20080520180528.GU28241@solarflare.com> <48331914.7050501@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Linux Netdev List" <netdev@vger.kernel.org>
To: "Patrick McHardy" <kaber@trash.net>,
	"Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:21599 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758854AbYETT62 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2008 15:58:28 -0400
Content-class: urn:content-classes:message
In-Reply-To: <48331914.7050501@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Shouldn't this mask the flags out of vlandev->features first?
> >   
> Yes, thanks.
> >> +	dev->features = real_dev->features & (NETIF_F_TSO | 
> NETIF_F_TSO6);
> >>     
> > This should also test the NETIF_F_VLAN_TSO flag and should copy the 
> > NETIF_F_ALL_CSUM and NETIF_F_SG flags since TSO requires those (see
> > register_netdevice() feature fix-up).  Peter pointed out that TX 
> > checksum offload for VLANs might be available even without TSO; the 
> > same goes for scatter-gather but I don't know whether it's 
> worth adding a flag for that.
> >   
> 
> Thanks, I added NETIF_F_SG to the VLAN TSO flags and added a 
> NETIF_F_VLAN_CSUM flag for TX checksums. I didn't change 
> GSO_SHIFT so far.

I've tested your latest patch with an in-house modified ixgbe driver,
both with CSUM and TSO.  This patch works great for adding and removing
the feature flags on demand.  Thanks for putting this together Patrick.

-PJ Waskiewicz
<peter.p.waskiewicz.jr@intel.com>
