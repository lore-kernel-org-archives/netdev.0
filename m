From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] ipv4: remove ip_rt_secret timer (v3)
Date: Fri, 7 May 2010 19:15:43 -0400
Message-ID: <20100507231543.GB2098@localhost.localdomain>
References: <20100506171639.GA5063@hmsreliant.think-freely.org>
 <20100507195528.GA3752@hmsreliant.think-freely.org>
 <1273266271.2325.16.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:36773 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750919Ab0EGXPx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 May 2010 19:15:53 -0400
Content-Disposition: inline
In-Reply-To: <1273266271.2325.16.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 07, 2010 at 11:04:31PM +0200, Eric Dumazet wrote:
> Le vendredi 07 mai 2010 =E0 15:55 -0400, Neil Horman a =E9crit :
> > Hey-
> > 	Sorry for the delay, but I got interested in Erics suggestion of
> > changing how we update rt_genid, and had a few thoughts.  Heres ver=
sion 3 of
> > this patch:
> >=20
>=20
> We have time, no hurry Neil.
>=20
Yeah, but if I don't keep on top of they slip off my todo list pretty q=
uick :)

> > Change Notes:
> >=20
> > 1) Removed the secret_interval binary interface entry in the list (=
forgot to do
> > that before)
> >=20
> > 2) Took Erics Suggestion to change the update for net->ipv4.rt_geni=
d.  Now
> > instead of doing a small incremental change, we simply grab 32 new =
random bits.
> >=20
>=20
> My suggestion was to initialize _once_ at boot time, the _full_ 32bit=
s.
>=20
Apologies, my read of your statement was that you wanted to randomize t=
he genid
every iteration, not just the first, to avoid the genid n+1 being withi=
n 256 of
the last genid.

> Not to change the perturbations, they are very fine, and need no extr=
a
> CONFIG_SOME_MAGICAL_SWITCH.
>=20
> We have a guarantee that no duplicates are delivered unless you perfo=
rm
> 2^24 generations in a short period of time.
>=20
Yes, I mentioned that, thats why I added the index check.

> But because you want to change full 32bits, you need a complex dupche=
ck
> thing ?
>=20
We don't _need_ it, thats why I made it configurable.

> > 3) The change in (2) got me thinking that part of the reason we use=
d the Jenkins
> > hash in rt_genid was to ensure non-repetion of id's in a short time=
 period
> > (which is important, so as not to inadvertently reuse route cache e=
ntries that
> > should be getting expired).  While extra randomness makes it harder=
 for
> > attackers to guess the secret, it makes it possible to return to pr=
eviously
> > guessed values as well (if they're lucky).  As such, I created a co=
nfigurable
> > option, CONFIG_GENID_DUPCHECK.  With this option on, the low order =
8 bits of the
> > genid are replaced with a rolling counter, that increments on each =
new genid.
> > This creates in effect, a 256 deep list of previously used genid va=
lues.  In
> > rt_drop we compare the genids for duplicates.  If we find that 2 ge=
nid values
> > have different indexes, but idential remaining bits, they are noted=
 as a repeat
> > genid, and we call rt_cache_invalidate to generate a new genid and =
avoid the
> > duplication problem.
> >=20
> >=20
>=20
> This is not necessary and over engineering if you ask me.
>=20
I can't say I disagree, but I was looking at this change based on your
suggestion.

> You now rely on probabilistic rules, and depends on get_random_bytes(=
)
> be really random, or a new CONFIG setting...
>=20
> What exact problem do you want to solve Neil ?
>=20
You know good and well what I'm trying to do here, don't be thick.  The=
 only
reason I was making changes to the genid in the first place was because=
 you were
asking for them.  I'm more than happy to make a simpler version of this=
=2E
Apologies for not interpreting your previous request the way you had in=
tended.

> Please submit your initial patch, with the small changes :
>=20
> 1) Remove the secret_interval binary interface entry in the list=20
>=20
> 2) Initialize full 32bits at struct net init time.
>=20
Yeah, ok.  I'll repost on monday.


Thanks
Neil



