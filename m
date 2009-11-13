From: Patrick McHardy <kaber@trash.net>
Subject: Re: Problem with VLANs and via-velocity driver
Date: Fri, 13 Nov 2009 12:11:18 +0100
Message-ID: <4AFD3ED6.2040606@trash.net>
References: <20091113033217.GQ838@cubit> <4AFCFF67.3060802@trash.net> <4AFD36C0.3090302@e-teleport.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kevin Shanahan <kmshanah@disenchant.net>, netdev@vger.kernel.org
To: technique@e-teleport.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47966 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756208AbZKMLLO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 06:11:14 -0500
In-Reply-To: <4AFD36C0.3090302@e-teleport.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

S=E9guier R=E9gis wrote:
> Patrick McHardy a =E9crit :
>> Kevin Shanahan wrote:
>> =20
>>> I've had some problems with getting a fairly simple (I thought) VLA=
N
>>> configuration working with the on board Via NICs on my Via M700
>>> board. Looks like as soon as a tagged VLAN interface is added, the
>>> underlying "raw" (untagged) interface stops responding.
>>>
>>>
>> There's some special-casing for VID 0 in velocity_init_cam_filter().
>> Does "ip link add link eth0 type vlan id 0" make any difference?
>> If not, does "ip link set eth0 promisc on"?
>>  =20
> When we patch the driver to support multiple vlan, we decide to use t=
he
> vlan 0 to desactivate the vlan filtering.

Why? The usual behaviour is to receive both tagged and untagged
frames.

> via-velocity: fix vlan receipt
>=20
> - vlans were using a single CAM register (see mac_set_vlan_cam)
> - setting the address filtering registers for vlans is not
>  needed when there is no vlan
>=20
> The non-tagged interface is filtered out as soon as a tagged
> (!=3D 0) interface is created. Its traffic appears again when an
> zero-tagged interface is created.

VID 0 doesn't mean untagged, it means the tag contains only a priority
value.
