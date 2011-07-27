From: Sven Eckelmann <sven@narfation.org>
Subject: Re: Re: [PATCHv4 10/11] drop_monitor: Use *_dec_not_zero instead of *_add_unless
Date: Wed, 27 Jul 2011 13:52:50 +0200
Message-ID: <2127465.xrCKehbL3A@sven-laptop.home.narfation.org>
References: <1311760070-21532-1-git-send-email-sven@narfation.org> <1311760070-21532-10-git-send-email-sven@narfation.org> <20110727105907.GA19001@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart3686055.hEzUH6zKZp"; micalg="pgp-sha512"; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7Bit
Cc: linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20110727105907.GA19001@hmsreliant.think-freely.org>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--nextPart3686055.hEzUH6zKZp
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

On Wednesday 27 July 2011 06:59:07 Neil Horman wrote:
> On Wed, Jul 27, 2011 at 11:47:49AM +0200, Sven Eckelmann wrote:
> > atomic_dec_not_zero is defined for each architecture through
> > <linux/atomic.h> to provide the functionality of
> > atomic_add_unless(x, -1, 0).
> > 
> > Signed-off-by: Sven Eckelmann <sven@narfation.org>
> > Cc: Neil Horman <nhorman@tuxdriver.com>
> > Cc: netdev@vger.kernel.org
> > ---
> > 
> >  net/core/drop_monitor.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> > 
> > diff --git a/net/core/drop_monitor.c b/net/core/drop_monitor.c
> > index 7f36b38..ef4a05d 100644
> > --- a/net/core/drop_monitor.c
> > +++ b/net/core/drop_monitor.c
> > @@ -137,7 +137,7 @@ static void trace_drop_common(struct sk_buff *skb,
> > void *location)
> > 
> >  	struct per_cpu_dm_data *data = &__get_cpu_var(dm_cpu_data);
> > 
> > -	if (!atomic_add_unless(&data->dm_hit_count, -1, 0)) {
> > +	if (!atomic_dec_not_zero(&data->dm_hit_count)) {
> > 
> >  		/*
> >  		
> >  		 * we're already at zero, discard this hit
> >  		 */
> 
> Wheres the patch that creates the per arch definition of this function?  I
> see the other posts in this series went to lkml, but the archives don't
> have the first in the series anywhere, which ostensibly adds the
> definition. Neil

Most architectures don't use a per architecture definition anymore, but a 
cross-architecture the definition in include/linux/atomic.h.

The 01/11 can be found in different archives under the message id 
1311760070-21532-1-git-send-email-sven@narfation.org ... for example gmane: 
http://article.gmane.org/gmane.linux.ports.arm.kernel/126704

Kind regards,
	Sven
--nextPart3686055.hEzUH6zKZp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCgAGBQJOL/wSAAoJEF2HCgfBJntGNz8P/2wDmBhHkECns7OOuBVqlMOz
r66gEhnNLTnztYkxL0GQ8/qH2OfsKDwfKF1i7tXkie0yqAhAxUtjMJUahxmX786G
Ek2nanC8Qbt5EmTrwx/bpzxLDM0UrOaLu1OcxA0AjT8qu/hJlzwicgr4fEElaanM
oL6VE0fTD2fk/7CYNEBC9omh4Om3pHWulj4pirEjR3pYqQ2/2mUO5RZ3blCNbts/
MOMrcrRC/p9ZFP/VanETM8xXcjD1nRDeKnliuYC+S0ZYB0ns6apPXBpflXdw2+4A
CVvfUcGk5ao0DaiggW6yaWxgshDSyT6gmy5fhXc/MKLvq6GswQKDBHjQZCO54fDM
upV+2gIZa0ehPdDxjQbSvmwY50U50jK9eDp22H/s6WOO+30RMVRrPKpAjhs310lL
Eql8hKRQP8/6xL27B9lbpIQvkUGNmFi1Uh/gS+kctOl6GUKONzmN40mHSyfS1+nf
mSUs3+eBmNz1arazwTwzCVC4SibXdC7WV6CwfNXQkceAvkLfOedV6J+wLmDgTE+0
mcdiIv7D3lnLdDOoyftlFkMOL0+hwAsg0MIhVaWE1BEL3zS4VoEyqI2ass7Vyw7U
7tR89XaaQKL4+na/NjO4BPulO4DZEVzFh6orxLMaUAbZpZ77+yG90TO4dtSuu3rv
ohcG9P/NR3n/KRZvxk1I
=cQPZ
-----END PGP SIGNATURE-----

--nextPart3686055.hEzUH6zKZp--
