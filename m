From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-2.6.26][VLAN]: Reduce memory consumed by vlan_group-s.
Date: Thu, 20 Mar 2008 15:22:18 +0100
Message-ID: <47E2731A.3090401@trash.net>
References: <47CC2ACF.6080903@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep18-int.chello.at ([213.46.255.22]:6491 "EHLO
	viefep14-int.chello.at" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755320AbYCTOWX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2008 10:22:23 -0400
In-Reply-To: <47CC2ACF.6080903@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov wrote:
> Currently each vlan_groupd contains 8 pointers on arrays with 512 
> pointers on struct net_device each :) Such a construction "in many 
> cases ... wastes memory".
> 
> My proposal is to allow for some of these arrays pointers be NULL,
> meaning that there are no devices in it. When a new device is added 
> to the vlan_group, the appropriate array is allocated.
> 
> The check in vlan_group_get_device's is safe, since the pointer
> vg->vlan_devices_arrays[x] can only switch from NULL to not-NULL.
> The vlan_group_prealloc_vid() is guarded with rtnl lock and is
> also safe.
> 
> I've checked (I hope that) all the places, that use these arrays 
> and found, that the register_vlan_dev is the only place, that can
> put a vlan device on an empty vlan_group.
> 
> Rough calculations shows, that after the patch a setup with a 
> single vlan dev (or up to 512 vlans with sequential vids) will 
> occupy approximately 8 times less memory.
> 
> The question I have is - does this patch makes sense, or a totally 
> new structures are required to store the vlan_devs?


Its an improvement, so I've applied it, thanks.

