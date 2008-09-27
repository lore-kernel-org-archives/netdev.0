From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: wireless vs. network namespaces (part II)
Date: Sat, 27 Sep 2008 12:01:25 +0200
Message-ID: <1222509685.3798.59.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-sKARt9uUGGt7Q4El8lIZ"
Cc: linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Jouni Malinen <j@w1.fi>
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-sKARt9uUGGt7Q4El8lIZ
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Eric,

You wrote, over a year ago:

> 2) Advanced routing.  Where someone is doing some weird thing like=20
>    testing sending packets and receiving them on the same machine.

and I was just thinking of doing exactly that :)

When looking into it, though, I noticed that you can generate some
breakage with wireless and network namespaces: you can move a wireless
netdev to a different namespace and then things will break down because
we internally use init_net to find it.

What I'd like to do in wireless is not allow moving netdevs between
namespaces, but rather move entire hardware devices between namespaces,
I see little value and great pain in trying to support virtual
interfaces from a single physical device showing up in different
namespaces, but I do see value in binding a physical device (wiphy) to a
namespace.

As far as I understand, to disallow moving them, I should set the
NETIF_F_NETNS_LOCAL flag on all devices, although that is sort of a
misnomer then because I'd be using it to indicate 'cannot switch
namespace'.=20

To really support this though, it seems we need to
 * put the wiphy list into struct net (this is currently a simple
   list_head, no fancy hashing)
 * give each struct wiphy a backpointer to the struct net, like netdev
   in the netdev struct
 * ensure that all netdevs created for this wiphy will have the right
   netns.

The latter part I'm unsure on, alloc_netdev_mq seems to always use
init_net so I can't put them into the right namespace to start with, but
because they're all "in there together" I can't allow switching
namespaces either.. Ideas?

johannes

--=-sKARt9uUGGt7Q4El8lIZ
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJI3gRxAAoJEKVg1VMiehFYyykQALBygrWuPrtzGv9SmdfyBI2j
sVl86IWX8Sxz6eYp4PtKbCgf5P+F/cPTkN9XlqZ7nkHPSErR4+8zaxt4vzmlLyvm
CsJ0918CvgL+chGGxqndhgYDDOXHKiB27XLykg/u71YXEqfSK/rKZUSyAkQZOuoX
/1I6HZmE4YjMis/BzV21nIPnddIUKFnH8+begMRV3JermsO4Cm68m39j7sEMXl9Z
NSAR6ZzVT2fX+Bs/MI518ns9jqFQurULam+F99lFr6a9tTt7ow6x+u5n/veVEA0J
77POmndeaR6q/UzF8Mz3Jm63h2r5vLAqp9g1DEgxncrTvPqyq2oiZmM7mgo5U+yP
5PgF4STAc+nyJYuwzgU0SG1iRk8EMbwSAMM0L1HInV7GkW9EDmxX3a9EKZ1SZQmH
Qn8dgkw2XwESAW+VYMDZEupem/fcfBfbbQoOQPC/a2tSaZqwIV/dHr49zgD2PJQD
2+HIsk19eFe7HuE2NRavAf2paKpS1jB8o+097ik4BzQ0vWbKB98uj2mwmDfrqcAD
4sAAM2sehReP4mBIYCW3i1Hq3YdxAiCh3gD3rQorlRVdsF8nk99qo5UyjUpVjKpi
XPnf/+8xmcp1OF2OwaTu5xMWBjx20PzgvQyog32DqfVP+/Z1+BU6QvwGHtVhHKSY
+FYls1zj3bdBDdKx0pHy
=jjOE
-----END PGP SIGNATURE-----

--=-sKARt9uUGGt7Q4El8lIZ--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
