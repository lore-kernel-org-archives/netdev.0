From: =?ISO-8859-15?Q?S=E9guier_R=E9gis?= <rseguier@e-teleport.net>
Subject: Re: Problem with VLANs and via-velocity driver
Date: Fri, 13 Nov 2009 11:36:49 +0100
Message-ID: <4AFD36C0.3090302@e-teleport.net>
References: <20091113033217.GQ838@cubit> <4AFCFF67.3060802@trash.net>
Reply-To: technique@e-teleport.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Kevin Shanahan <kmshanah@disenchant.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.e-teleport.net ([213.190.64.162]:59200 "EHLO
	smtp.e-teleport.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753835AbZKMLC7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 06:02:59 -0500
In-Reply-To: <4AFCFF67.3060802@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy a =E9crit :
> Kevin Shanahan wrote:
>  =20
>> Hi,
>>
>> I've had some problems with getting a fairly simple (I thought) VLAN
>> configuration working with the on board Via NICs on my Via M700
>> board. Looks like as soon as a tagged VLAN interface is added, the
>> underlying "raw" (untagged) interface stops responding.
>>
>> ...
>>
>> A bit of searching found a few references to similar problems going
>> back a few years (2005, 2007). Sounded like there were some driver
>> issues, but it wasn't clear from the messages I found whether they
>> were believed to be fixed or not. I tried the same test using a
>> differnt NIC with the tg3 driver and there were no problems, so it
>> looks to me like it's still a via-velocity issue. Unfortunately I
>> don't have room to add NICs to this machine and need to use the on
>> board Via hardware.
>>    =20
>
> There's some special-casing for VID 0 in velocity_init_cam_filter().
> Does "ip link add link eth0 type vlan id 0" make any difference?
> If not, does "ip link set eth0 promisc on"?
>  =20
When we patch the driver to support multiple vlan, we decide to use the=
=20
vlan 0 to desactivate the vlan filtering.

via-velocity: fix vlan receipt

- vlans were using a single CAM register (see mac_set_vlan_cam)
- setting the address filtering registers for vlans is not
  needed when there is no vlan

The non-tagged interface is filtered out as soon as a tagged
(!=3D 0) interface is created. Its traffic appears again when an
zero-tagged interface is created.

Tested on Via Epia SN (VT6130 chipset) with several vlans whose
tag was above or beyond 255.

Signed-off-by: S=E9guier R=E9gis <rseguier@e-teleport.net>
Acked-by: Francois Romieu <romieu@fr.zoreil.com>
Signed-off-by: Jeff Garzik <jgarzik@redhat.com>
--=20
R=E9gis S=E9guier
