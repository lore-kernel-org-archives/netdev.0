From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 4/6] vlan: Optimize multiple unregistration
Date: Thu, 29 Oct 2009 14:45:44 +0100
Message-ID: <4AE99C88.40403@trash.net>
References: <4AE728A9.2080209@gmail.com> <4AE8A425.1000600@trash.net> <4AE8ADE7.1010909@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:50555 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752773AbZJ2Npt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 09:45:49 -0400
In-Reply-To: <4AE8ADE7.1010909@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Patrick McHardy a =E9crit :
>>> +{
>>> +	LIST_HEAD(list);
>>> +	int i;
>>> +	struct net_device *vlandev;
>>> +	struct vlan_group save;
>>> +
>>> +	memcpy(&save, grp, sizeof(save));
>>> +	memset(&grp->vlan_devices_arrays, 0, sizeof(grp->vlan_devices_arr=
ays));
>> This shouldn't be necessary since the lower device is already in the
>> process of being unregistered. If it was necessary, it could cause
>> crashes since the individual pointers are not set to zero atomically=
=2E
>> Or maybe I'm misunderstanding the purpose entirely :)
>=20
> Very good point indeed, even if in practice memset() use long word tr=
ansferts
>=20
> I'll make a cleanup patch, or do you want to do it ?

I can take care of this, patch will follow shortly.

