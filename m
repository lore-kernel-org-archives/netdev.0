From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont" <remi@remlab.net>
Subject: Re: Network isolation with RLIMIT_NETWORK, cont'd.
Date: Sun, 13 Dec 2009 10:32:20 +0200
Message-ID: <200912131032.24251.remi@remlab.net>
References: <20091213034418.GA4416@heat>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	Andi Kleen <andi@firstfloor.org>, David Lang <david@lang.hm>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
	Bryan Donlan <bdonlan@gmail.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	"C. Scott Ananian" <cscott@cscott.net>,
	James Morris <jmorris@namei.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Bernie Innocenti <bernie@codewiz.org>,
	Mark Seaborn <mrs@mythic-beasts.com>
To: Michael Stone <michael@laptop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:45904 "HELO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751775AbZLMIc2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Dec 2009 03:32:28 -0500
In-Reply-To: <20091213034418.GA4416@heat>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Hello,

Le dimanche 13 d=E9cembre 2009 05:44:18 Michael Stone, vous avez =E9cri=
t :
> You were all meant to be included on the CC-list for the letter and p=
atches
> which I just sent to lkml:
>=20
>    http://lkml.org/lkml/2009/12/12/149

You explicitly mention the need to connect to the X server over local s=
ockets. =20
But won't that allow the sandboxed application to send synthetic events=
 to any=20
other X11 applications? Hence unless the whole X server has restricted =
network=20
access, this seems a bit broken? D-Bus, which also uses local sockets, =
will=20
exhibit similar issues, as will any unrestricted IPC mechanism in fact.

I am not sure if restricting network access but not other file descript=
ors=20
makes that much sense... ? Then again, I'm not entirely clear what you =
are=20
trying to solve.

If I had to sandbox something, I'd drop the process file limit to 0. Th=
at will=20
effectively cut off network, file system, and POSIX IPCs. Unfortunately=
, the=20
process can still use SysV IPC, ptrace(), and send signals to others. S=
o those=20
are the gaps I would first try to contain.

--=20
R=E9mi Denis-Courmont
http://www.remlab.net/
http://fi.linkedin.com/in/remidenis
