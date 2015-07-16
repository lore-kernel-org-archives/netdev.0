From: Marc Dietrich <marvin24@gmx.de>
Subject: Re: "ss -p" segfaults
Date: Thu, 16 Jul 2015 08:37:49 +0200
Message-ID: <1587116.GuyXMaAcLE@fb07-iapwap2>
References: <2282663.K45lFmE7Zp@fb07-iapwap2> <20150715185751.GA19820@angus-think.lan> <20150715222238.GA13019@angus-think.lan>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart3199073.lAOluJaUMV"; micalg="pgp-sha256"; protocol="application/pgp-signature"
Cc: "Rustad, Mark D" <mark.d.rustad@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.21]:52088 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751476AbbGPGiG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jul 2015 02:38:06 -0400
In-Reply-To: <20150715222238.GA13019@angus-think.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart3199073.lAOluJaUMV
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

Am Donnerstag, 16. Juli 2015, 01:22:38 schrieb Vadim Kochan:
> On Wed, Jul 15, 2015 at 09:57:51PM +0300, Vadim Kochan wrote:
> > On Wed, Jul 15, 2015 at 06:52:49PM +0000, Rustad, Mark D wrote:
> > > > On Jul 15, 2015, at 9:49 AM, Rustad, Mark D <mark.d.rustad@intel.com> 
wrote:
> > > >> On Jul 15, 2015, at 8:12 AM, Vadim Kochan <vadim4j@gmail.com> wrote:
> > > >> Would you please check this fix ?
> > > >> 
> > > >> diff --git a/misc/ss.c b/misc/ss.c
> > > >> index 03f92fa..3a826e4 100644
> > > >> --- a/misc/ss.c
> > > >> +++ b/misc/ss.c
> > > >> @@ -683,8 +683,8 @@ static inline void sock_addr_set_str(inet_prefix
> > > >> *prefix, char **ptr)
> > > >> 
> > > >> static inline char *sock_addr_get_str(const inet_prefix *prefix)
> > > >> {
> > > >> -    char *tmp ;
> > > >> -    memcpy(&tmp, prefix->data, sizeof(char *));
> > > >> +    char *tmp;
> > > >> +    memcpy(&tmp, &prefix->data[0], sizeof(char *));
> > > >> 
> > > >>    return tmp;
> > > >> 
> > > >> }
> > > > 
> > > > That surely is not a fix! The destination of the memcpy is the address
> > > > of an uninitialized stack variable! Both versions are equally bad.> > 
> > > I probably over-reacted, but using memcpy to access a pointer in this
> > > way is just ugly. For one thing, it circumvents any sanity-checking
> > > that the compiler can do. And changing the prefix->data to
> > > &prefix->data[0] should be exactly the same thing and therefore should
> > > not fix anything. Anyway, never mind that.
> > > 
> > > Looking at more of the code, it looks to me like the the string pointer
> > > in data can sometimes point to a literal string instead of allocated
> > > memory when proc is in use. Free would not be happy with that. Look at
> > > the use of variable peer in function unix_stats_print.> 
> > Yes that right, I am already looking on this ...
> > 
> > > --
> > > Mark Rustad, Networking Division, Intel Corporation
> 
> I did partially revert of the buggy commit and it does not crash, but I will
> do more testing, and after will send the patch and will try to prepare some
> test scripts for ss.
> 
> The crash appears only if to dump processes info from /proc, which might
> be caused that netlink stats returned error, probably by wrong request
> (not supported attribute or flag ?).

the reason it uses proc for me is my self compiled (and trimmed) kernel which 
disabled all *_diag modules which seem to be required by ss. I didn't know 
this. On the other hand, I managed to find a bug this way :-)

Marc


--nextPart3199073.lAOluJaUMV
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJVp1E9AAoJEKyeR39HFBto3YcH/0KTGaMu7WLeezfiWHJHXeb9
QuC/QSzT2/P/kIbdsWrIMTfE4d9juRF5MQ51FgKOpHpNUf3xgNvcLfHAx3gNjE6a
e3BcXZgTC99XDphhfaA16BzL+GodiK+DJ9rnVZxciD7HAy7wej1Qn888eU3OiIFm
cKESULddTCvJnIql61tQPS3l5VZBkuGrg/Ui4YB1JTq8QhvNdwE4gYHQWQAPcNkH
MAybpg0cbvOgV9KOvuU5ryJOjlArLbYoN0W5mGH6bqvcWvR4p6g9GIlxMBhsxIF3
oHR18BKfZCt2ZmBva5Q9mrTOwo7zBfncrT3lLHKrnpNriGly4r/f+Buc2qTgQEU=
=MNEH
-----END PGP SIGNATURE-----

--nextPart3199073.lAOluJaUMV--
