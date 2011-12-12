From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] kref: add function for reading kref value
Date: Mon, 12 Dec 2011 18:42:34 +0100
Message-ID: <1323711754.2583.14.camel@edumazet-laptop>
References: <1323693892-11570-1-git-send-email-dbaluta@ixiacom.com>
	 <20111212150255.GA7506@kroah.com>
	 <CAEnQRZBiVDAHH+uZ=Ugk=UP5qSvvMViGTM-bRWr+E27zivOUug@mail.gmail.com>
	 <1323703934.1765.15.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAEnQRZCZdPw9eWVmdvhtF7KCQkYpLMrkhv5qd5xYckxWksN+0w@mail.gmail.com>
	 <1323704494.1765.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAEnQRZAt0X6cxGLgLUVTB9rzLKVYLEnh=azS9WOyKAkUZEpj4g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Greg KH <greg@kroah.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, adobriyan@gmail.com
To: Daniel Baluta <dbaluta@ixiacom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAEnQRZAt0X6cxGLgLUVTB9rzLKVYLEnh=azS9WOyKAkUZEpj4g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 12 d=C3=A9cembre 2011 =C3=A0 18:42 +0200, Daniel Baluta a =C3=A9=
crit :

> Yes, but you have to do this each time you start debugging, for a
> particular referenced counted object.
>=20

What a big deal.

> We must find a clever solution to avoid the noise. (e.g use
> /proc, /sysfs, /debugfs options to trigger dumping info for
> some/all objects with a certain state).
>=20
> Usecase:
>=20
> At some point we need to know all objects with refcount X,
> and their history of get/put operations.
>=20
> For us it would have been very useful when debugging dev
> refcnts problems. With the current implementation kernel
> only dumped info at dev.c:5429:
>=20

current on your git repo maybe, not on ours :(

> printk(KERN_EMERG "unregister_netdevice: "
>        waiting for %s to become free. Usage "
>        count =3D %d\n",
>        dev->name, atomic_read(&dev->refcnt));
>=20

This is a very good example where you _cannot_ use kref, since we now
use a percpu refcnt fot netdevice.
