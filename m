From: Sascha Silbe <sascha-ml-reply-to-2011-2@silbe.org>
Subject: Re: [PATCH] Add libertas_disablemesh module parameter to disable mesh
	interface
Date: Fri, 13 May 2011 15:16:31 +0200
Message-ID: <1305290935-sup-4547@xo15-sascha.sascha.silbe.org>
References: <1305118354-17337-1-git-send-email-silbe@activitycentral.com>
	<1305169898.8054.19.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2970142355494864435=="
Cc: libertas-dev <libertas-dev@lists.infradead.org>,
	netdev <netdev@vger.kernel.org>, John@xo15-sascha.sascha.silbe.org,
	linux-wireless <linux-wireless@vger.kernel.org>, linville@tuxdriver.com,
	linux-kernel <linux-kernel@vger.kernel.org>,
	W.Linville@xo15-sascha.sascha.silbe.org, devel <devel@lists.laptop.org>
To: Dan Williams <dcbw@redhat.com>
Return-path: <devel-bounces@lists.laptop.org>
In-reply-to: <1305169898.8054.19.camel@dcbw.foobar.com>
List-Unsubscribe: <http://lists.laptop.org/listinfo/devel>,
	<mailto:devel-request@lists.laptop.org?subject=unsubscribe>
List-Archive: <http://lists.laptop.org/pipermail/devel>
List-Post: <mailto:devel@lists.laptop.org>
List-Help: <mailto:devel-request@lists.laptop.org?subject=help>
List-Subscribe: <http://lists.laptop.org/listinfo/devel>,
	<mailto:devel-request@lists.laptop.org?subject=subscribe>
Mime-version: 1.0
Sender: devel-bounces@lists.laptop.org
Errors-To: devel-bounces@lists.laptop.org
List-Id: netdev.vger.kernel.org


--===============2970142355494864435==
Content-Type: multipart/signed; boundary="=-1305292597-186208-1562-8493-5-="; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit


--=-1305292597-186208-1562-8493-5-=
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Excerpts from Dan Williams's message of Thu May 12 05:11:36 +0200 2011:
> On Wed, 2011-05-11 at 14:52 +0200, Sascha Silbe wrote:
> > This allows individual users and deployments to disable mesh support =
at
> > runtime, i.e. without having to build and maintain a custom kernel.

> Does the mesh interface somehow cause problems, even when nothing is
> using it?

Some people suspect it does, but there's no hard data showing that. But
then the problems are often hard to reproduce in the first place, so
proving a correlation with mesh is even harder.

The hardware based mesh support is based on an outdated draft of
802.11s and not interoperable with any other device AFAIK. For most
users Ad-hoc networks are the better option. Disabling mesh support as
low-level as possible makes it less likely that any remains are causing
trouble. With at least four layers (firmware, kernel, NM, Sugar)
involved in managing connectivity and one of the (firmware) being closed
source, I prefer to simplify things by eliminating three layers for
functionality we don't intend to use. It makes debugging (and
blaming ;) ) a lot easier.

In the field, mesh support is currently disabled using
/sys/class/net/eth0/lbs_mesh. However, it comes back after resume
(possibly only if powercycled) and needs to be disabled again by
post-resume hacks. Race conditions with NM are possible.

A user space option would be to teach NM to disable mesh support (at
runtime - we don't want to ship a custom NM package). I'd expect the
patch to be much more invasive than the one posted for libertas.

Sascha

-- =

http://sascha.silbe.org/
http://www.infra-silbe.de/

--=-1305292597-186208-1562-8493-5-=
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.1.0beta1 (GNU/Linux)

iQEcBAEBCgAGBQJNzS8vAAoJELpz82VMF3Da94UH/Rluny57CQsZHDC+3ykgWRnc
+1LkVmBqZBDElLmRCsoPU2qPje2V6Hs+f17/GSHiYS3xVRCG7jgkFv5d27ix2b+L
s6sSk4up44PZD39uLsquDZjgXlOKLHbISRsClbzh0C8d65o5LweJTot67q1lY3Qu
Q3jheEgkoFzLwePxiGRqKW0i5o0pGCPlPcS7fzn2kyhPxOD/f6FPncGSv9o9iPdB
UAoSr+QvbQWtCAuOjOzdJsOPWInNr566jhpchi0i9UUChdTs4MjH9SKSVh15qaOg
XCYhXngwJqfMXbpr5++SF2SMd32Vk62uLNId9XxTf1GKuTOoebf2a5DzGZ89sqs=
=C+AO
-----END PGP SIGNATURE-----

--=-1305292597-186208-1562-8493-5-=--

--===============2970142355494864435==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Devel mailing list
Devel@lists.laptop.org
http://lists.laptop.org/listinfo/devel

--===============2970142355494864435==--
