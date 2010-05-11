From: Vivek Kashyap <kashyapv@us.ibm.com>
Subject: Re: [PATCH] virtif: initial interface extensions
Date: Tue, 11 May 2010 10:15:35 -0700 (PDT)
Message-ID: <alpine.LFD.2.00.1005102058200.4272@vk>
References: <C80DF1EC.2FFE0%scofeldm@cisco.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Cc: Arnd Bergmann <arnd@arndb.de>, Stefan Berger <stefanb@us.ibm.com>,
	netdev@vger.kernel.org
To: Scott Feldman <scofeldm@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:58676 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751928Ab0EKRPw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 May 2010 13:15:52 -0400
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e39.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id o4BH7DiG027739
	for <netdev@vger.kernel.org>; Tue, 11 May 2010 11:07:13 -0600
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o4BHFftn094544
	for <netdev@vger.kernel.org>; Tue, 11 May 2010 11:15:43 -0600
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o4BHFbQS029607
	for <netdev@vger.kernel.org>; Tue, 11 May 2010 11:15:38 -0600
In-Reply-To: <C80DF1EC.2FFE0%scofeldm@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> I'm don't think this is going in the right direction.  We're talking a
> pretty simple concept of a port-profile used to configure the virtual port
> backing a VM i/f to something that's trying to munge disjoint protocols
> based on pre-standard work into a single API.  It's forcing all those

The multi-channel setup and VDP can live, and are designed to live
together:
  - multiple channels per link (setup by the bridge) -- CDCP
  - association of a vsi (virtual interface) to bridge ports -- VDP

However, their implementation can be pursued separately.

> pre-standard protocol details into the API, into the XML, and into the mgmt
> software (libvirt), and into the admin's lap.
>
> I want the API to pass a port-profile name plus other information associated

The problem with defining a 'name' as the lookup key to another database is 
that one then requires additional management mechanisms to describe, 
maintain, and map to the real values needed. It lands in admin's lap 
anyway by a different path.


> with the VM i/f to some mgmt object which can setup the virtual port backing
> the VM i/f.  (And unset it).  Using netlink for API let's that object be in
> user- or kernel-space software, hardware or firmware.  How the object sets
> up the virtual port based on the passed port-profile is beyond the scope of
> the API.

Agree.  See Stefan's last patch in libvirt - it converges 802.1Qbh/portprofile
and 802.1Qbg quite well. The netlink message can be deciphered by the
recipient and meets the advantages below.  (Or, one could use a direct 
unix domain socket to communicate with a daemon as well).


>
> My last port-profile patch is this API.  It gives us this:
>
>    1) single netlink msg for kernel- and user-space
>    2) single parameter set from sender's perspective (libvirt)
>    3) single XML representation of parameters
>    4) single code path in kernel and libvirt
>    5) (potential) cross-vendor-switch VM migration
>    6) admin-friendly port-profile names
>    7) allows pre-standard (802.1Qbg/bh) details to change
>       without bogging down the API
>
> What I proposed on the libvirt list is to maintain a mapping database from
> port-profile to vendor-specific or protocol-specific parameters.  Using VDP
> as an example, a port-profile would resolve the VDP tuple:
>
>     port-profile: "joes-garage"   --->  VSI Manager ID: 15
>                                         VSI Type ID: 12345
>                                         VSI Type ID Ver: 1
>                                         other VSI settings (preassociate)
>
> How the mapping database is maintained is beyond the scope of the API.

Yes, but that will add another mechanism to set the mappings. The 
xml posted (on libvirt) defines the vsi values and avoids this 
additional management. It also allows for port-profile name for 802.1Qbh.

thanks
 	Vivek


