From: Patrick McHardy <kaber@trash.net>
Subject: Re: Problem with VLANs and via-velocity driver
Date: Thu, 19 Nov 2009 16:17:58 +0100
Message-ID: <4B0561A6.3020502@trash.net>
References: <20091113033217.GQ838@cubit> <4AFCFF67.3060802@trash.net> <4AFD36C0.3090302@e-teleport.net> <4AFD3ED6.2040606@trash.net> <4AFD4595.1070904@e-teleport.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kevin Shanahan <kmshanah@disenchant.net>, netdev@vger.kernel.org
To: =?ISO-8859-15?Q?S=E9guier_R=E9gis?= <rseguier@e-teleport.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44798 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752346AbZKSPRx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2009 10:17:53 -0500
In-Reply-To: <4AFD4595.1070904@e-teleport.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

S=E9guier R=E9gis wrote:
> Patrick McHardy a =E9crit :
>>
>>>> There's some special-casing for VID 0 in velocity_init_cam_filter(=
).
>>>> Does "ip link add link eth0 type vlan id 0" make any difference?
>>>> If not, does "ip link set eth0 promisc on"?
>>>>        =20
>>> When we patch the driver to support multiple vlan, we decide to use=
 the
>>> vlan 0 to desactivate the vlan filtering.
>>>    =20
>>
>> Why? The usual behaviour is to receive both tagged and untagged
>> frames.
>>  =20
> We decide this with fran=E7ois as an alternative to desactivate the N=
IC
> vlan filtering instead of creating a modul parameter.
> The vlan id 0 need to be created but not necessary activate.

That doesn't seem like a good idea since it behaves differently than
any other driver supporting VLAN.

> In september 2008, we had a discution about exactly the same problem.
> You speak about the possibility of an ALLVLAN device flag.

That was meant for the case where hardware filtering for specific VLANs
is active and you want to see traffic of VLANs not configured locally
without switching to promiscous mode.

> I think i proposed a patch to desactivate NIC vlan filtering when we =
are
> in promisc mode but not used.

Yes, in promiscous mode VLAN filtering should be disabled.
