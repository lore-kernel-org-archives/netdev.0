From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: [PATCH 09/14] Phonet: allocate and initialize new sockets
Date: Wed, 17 Sep 2008 11:30:47 +0300
Message-ID: <200809171130.47361.remi.denis-courmont@nokia.com>
References: <200809161757.38571.remi.denis-courmont@nokia.com> <1221577694-4513-9-git-send-email-remi.denis-courmont@nokia.com> <48CFFE2C.7050908@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "ext Pavel Emelyanov" <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:61216 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752593AbYIQIbQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2008 04:31:16 -0400
In-Reply-To: <48CFFE2C.7050908@openvz.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Tuesday 16 September 2008 21:42:52 ext Pavel Emelyanov, you wrote:
> > @@ -71,8 +73,22 @@ static int pn_socket_create(struct net *net, str=
uct
> > socket *sock, int protocol) goto out;
> >  	}
> >
> > -	/* TODO: create and init the struct sock */
> > -	err =3D -EPROTONOSUPPORT;
> > +	sk =3D sk_alloc(net, PF_PHONET, GFP_KERNEL, pnp->prot);
> > +	if (sk =3D=3D NULL) {
> > +		err =3D -ENOMEM;
> > +		goto out;
> > +	}
>
> This turns to be a little bit messy wrt net namespaces.
> Look - you allow for sockets to be created (and isolated from each
> other) in each namespace,

I expect pn_socket_create() should forbid this, no?

    if (net !=3D &init_net)
            return -EAFNOSUPPORT;
    /* ... */
    sk =3D sk_alloc(net, PF_PHONET, GFP_KERNEL, pnp->prot);

> the list of devices is global,

Hmmm, good point. Should I forbid adding an address to devices outside =
the=20
initial namespace? what about a device with an existing address being=20
migrated?

> whilst the sysctls are visible in init_net only...

Regards,

--=20
R=E9mi Denis-Courmont
Maemo Software, Nokia Devices R&D
