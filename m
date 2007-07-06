From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: multicasting netlink messages to groups > 31 from userspace
Date: Fri, 06 Jul 2007 12:50:54 +0200
Message-ID: <1183719054.3818.105.camel@johannes.berg>
References: <1183492286.4021.21.camel@johannes.berg>
	 <1183643610.5163.76.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-3JkSiA0G8n3ziUv0blQ1"
Cc: netdev <netdev@vger.kernel.org>, Patrick McHardy <kaber@trash.net>,
	Thomas Graf <tgraf@suug.ch>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:36580 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751861AbXGFKty (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2007 06:49:54 -0400
In-Reply-To: <1183643610.5163.76.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-3JkSiA0G8n3ziUv0blQ1
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2007-07-05 at 09:53 -0400, jamal wrote:
> This email captures the essence of the thread, so let me start here.=20
> I dont know if i read well enough all the details, but i think i have a
> good grasp of the discusion.

:)

> The DoS issue is applicable IMO to any IPC. i.e
> if i have access to sending to you, i can send you many messages and
> fill up your unix socket rcvq etc.

Yeah, good point.

> - In addition to the netlink sock open/close that Patrick mentioned, you
> can listen to generic netlink events on the accounting/task netlink and
> find out when processes are created/destroyed if that is useful. I
> couldnt tell why you needed to know this...

No, I need to know if a specific socket that I was using in the kernel
to communicate with a special userspace process is still open, but the
notifier seems to address that. I haven't tested it yet.

> Yes, this is TheWayItHasBeen(tm).
> Patrick had a patch a while back to allow for subscribing to higher
> groups because bind() has a similar issue in that it allows you only to
> subscribe to the first 32. So it is logical to fix connect, and sendmsg
> in a similar fashion.

Yeah, that's the sock opt.

> Fixing connect IMO would be a good first start because if you do
> connect() to the right group(s) before sendsmg() you could send
> to the correct group.
>=20
> > It would of course be possible to add a new sockopt
> > NETLINK_{SET,GET}_DST_GROUP,=20
>=20
> This maybe your best first starting option IMO. It will be in similar
> spirit to Patricks bind() fix.

Right.

> Iirc, i dont think we can do that anymore. But we can introduce a new
> scheme to allow for this. For example, could you not use CMSG to specify
> an explicit list of groups on sendmsg? IIRC, Patrick used CMSG to report
> on rcv which group a msg was received on.=20

I'll have to look into it. Patrick suggested this as well in the reply,
but I think it's not going to be too important to me right now,
depending on the outcome in the wireless discussion.

johannes

--=-3JkSiA0G8n3ziUv0blQ1
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGjh6O/ETPhpq3jKURAm+RAJwOKsXNYGunM/khMse0e1DhMS+h0gCfey88
uTa/hZL85NShPsyG6Sk+QfY=
=mxm9
-----END PGP SIGNATURE-----

--=-3JkSiA0G8n3ziUv0blQ1--

