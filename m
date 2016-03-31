From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Question on rhashtable in worst-case scenario.
Date: Thu, 31 Mar 2016 09:46:45 +0200
Message-ID: <1459410405.4576.8.camel@sipsolutions.net>
References: <56F9941A.3080501@candelatech.com>
	 <56FAAA6D.3070806@candelatech.com>
	 <1459329252.2055.1.camel@sipsolutions.net>
	 <20160330.123821.328761526754742195.davem@davemloft.net>
	 <56FC0445.6010200@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, herbert@gondor.apana.org.au,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	tgraf@suug.ch
To: Ben Greear <greearb@candelatech.com>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56FC0445.6010200@candelatech.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-03-30 at 09:52 -0700, Ben Greear wrote:

> If someone can fix rhashtable, then great.
> I read some earlier comments [1] back when someone else reported
> similar problems, and the comments seemed to indicate that rhashtable
> was broken in this manner on purpose to protect against hashing
> attacks.
>=20
> If you are baking in this type of policy to what should be a basic
> data-type, then it is not useful for how it is being used in
> the mac80211 stack.
>=20
> [1]=C2=A0=C2=A0http://lkml.iu.edu/hypermail/linux/kernel/1512.2/01681=
=2Ehtml
>=20

That's not really saying it's purposely broken, that's more saying that
Herbert didn't see a point in fixing a case that has awful behaviour
already.

However, I'm confused now - we can much more easily live with
*insertion* failures, as the linked email indicates, than *deletion*
failures, which I think you had indicated originally. Are you really
seeing *deletion* failures?

If there are in fact *deletion* failures then I think we really need to
address those in rhashtable, no matter the worst-case behaviour of the
hashing or keys, since we should be able to delete entries in order to
get back to something reasonable. Looking at the code though, I don't
actually see that happening.

If you're seeing only *insertion* failures, which you indicated in the
root of this thread, then I think for the general case in mac80211 we
can live with that - we use a seeded jhash for the hash function, and
since in the general case we cannot accept entries with identical MAC
addresses to start with, it shouldn't be possible to run into this
problem under normal use cases.

In this case, I think perhaps you can just patch your local system with
the many interfaces connecting to the same AP to add the parameter
Herbert suggested (.insecure_elasticity =3D true in sta_rht_params). Th=
is
is, after all, very much a case that "normal" operation doesn't even
get close to.

johannes
