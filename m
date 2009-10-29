From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 4/6] vlan: Optimize multiple unregistration
Date: Thu, 29 Oct 2009 15:30:14 +0100
Message-ID: <4AE9A6F6.5040209@gmail.com>
References: <4AE728A9.2080209@gmail.com> <4AE8A425.1000600@trash.net> <4AE8ADE7.1010909@gmail.com> <4AE99C88.40403@trash.net> <4AE9A554.8030207@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:47210 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752483AbZJ2OaM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 10:30:12 -0400
In-Reply-To: <4AE9A554.8030207@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy a =E9crit :
> Patrick McHardy wrote:
>> Eric Dumazet wrote:
>>> Patrick McHardy a =E9crit :
>>>>> +{
>>>>> +	LIST_HEAD(list);
>>>>> +	int i;
>>>>> +	struct net_device *vlandev;
>>>>> +	struct vlan_group save;
>>>>> +
>>>>> +	memcpy(&save, grp, sizeof(save));
>>>>> +	memset(&grp->vlan_devices_arrays, 0, sizeof(grp->vlan_devices_a=
rrays));
>>>> This shouldn't be necessary since the lower device is already in t=
he
>>>> process of being unregistered. If it was necessary, it could cause
>>>> crashes since the individual pointers are not set to zero atomical=
ly.
>>>> Or maybe I'm misunderstanding the purpose entirely :)
>>> Very good point indeed, even if in practice memset() use long word =
transferts
>>>
>>> I'll make a cleanup patch, or do you want to do it ?
>> I can take care of this, patch will follow shortly.
>=20
> How about this? I moved the code back into vlan_device_event() since
> its now only a very minimal change to the original code.
>=20
> vlan-orig.diff contains the diff between the original code and the
> code after this patch for reference.
>=20
>=20

I have no problem with this solution, but I wonder why you re-added the=
 curious

			/* unregistration of last vlan destroys group, abort
			 * afterwards */
			if (grp->nr_vlans =3D=3D 1)
				i =3D VLAN_GROUP_ARRAY_LEN;

			unregister_vlan_dev(vlandev, &list);

while doing

	unregister_vlan_dev(vlandev, &list);
	if (grp->nr_vlans =3D=3D 0)
		break;

seems more natural :)
