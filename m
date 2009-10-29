From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 4/6] vlan: Optimize multiple unregistration
Date: Thu, 29 Oct 2009 15:33:14 +0100
Message-ID: <4AE9A7AA.70107@trash.net>
References: <4AE728A9.2080209@gmail.com> <4AE8A425.1000600@trash.net> <4AE8ADE7.1010909@gmail.com> <4AE99C88.40403@trash.net> <4AE9A554.8030207@trash.net> <4AE9A6F6.5040209@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51658 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753509AbZJ2OdR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 10:33:17 -0400
In-Reply-To: <4AE9A6F6.5040209@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Patrick McHardy a =E9crit :
>> How about this? I moved the code back into vlan_device_event() since
>> its now only a very minimal change to the original code.
>>
>> vlan-orig.diff contains the diff between the original code and the
>> code after this patch for reference.
>>
>>
>=20
> I have no problem with this solution, but I wonder why you re-added t=
he curious
>=20
> 			/* unregistration of last vlan destroys group, abort
> 			 * afterwards */
> 			if (grp->nr_vlans =3D=3D 1)
> 				i =3D VLAN_GROUP_ARRAY_LEN;
>=20
> 			unregister_vlan_dev(vlandev, &list);
>=20
> while doing
>=20
> 	unregister_vlan_dev(vlandev, &list);
> 	if (grp->nr_vlans =3D=3D 0)
> 		break;
>=20
> seems more natural :)

Indeed, but unregister_vlan_dev() destroys the group once the
count has reached zero, so we must not access it after that.
