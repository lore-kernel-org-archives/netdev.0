From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH 09/14] Phonet: allocate and initialize new sockets
Date: Fri, 19 Sep 2008 14:14:08 +0400
Message-ID: <48D37B70.2010702@openvz.org>
References: <200809161757.38571.remi.denis-courmont@nokia.com> <1221577694-4513-9-git-send-email-remi.denis-courmont@nokia.com> <48CFFE2C.7050908@openvz.org> <200809171130.47361.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?ISO-8859-1?Q?R=E9mi_Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:37578 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751104AbYISKOR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Sep 2008 06:14:17 -0400
In-Reply-To: <200809171130.47361.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

R=E9mi Denis-Courmont wrote:
> 	Hello,
>=20
> On Tuesday 16 September 2008 21:42:52 ext Pavel Emelyanov, you wrote:
>>> @@ -71,8 +73,22 @@ static int pn_socket_create(struct net *net, str=
uct
>>> socket *sock, int protocol) goto out;
>>>  	}
>>>
>>> -	/* TODO: create and init the struct sock */
>>> -	err =3D -EPROTONOSUPPORT;
>>> +	sk =3D sk_alloc(net, PF_PHONET, GFP_KERNEL, pnp->prot);
>>> +	if (sk =3D=3D NULL) {
>>> +		err =3D -ENOMEM;
>>> +		goto out;
>>> +	}
>> This turns to be a little bit messy wrt net namespaces.
>> Look - you allow for sockets to be created (and isolated from each
>> other) in each namespace,
>=20
> I expect pn_socket_create() should forbid this, no?

Well, to be honest, I'd prefer making this ns aware from the very
beginning, but not to force you make things you (probably) don't want
to, I will answer - yes, please, ban this protocol for !init_ns :)

>     if (net !=3D &init_net)
>             return -EAFNOSUPPORT;
>     /* ... */
>     sk =3D sk_alloc(net, PF_PHONET, GFP_KERNEL, pnp->prot);
>=20
>> the list of devices is global,
>=20
> Hmmm, good point. Should I forbid adding an address to devices outsid=
e the=20
> initial namespace? what about a device with an existing address being=
=20
> migrated?
>=20
>> whilst the sysctls are visible in init_net only...
>=20
> Regards,
>=20

