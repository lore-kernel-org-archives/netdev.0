From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Where exactly will arch_fast_hash be used
Date: Sun, 07 Dec 2014 14:52:31 +0100
Message-ID: <1417960351.17658.43.camel@localhost>
References: <20141207133056.25209.qmail@ns.horizon.com>
	 <1417959696.17658.37.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, herbert@gondor.apana.org.au,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org, tgraf@suug.ch
To: George Spelvin <linux@horizon.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1417959696.17658.37.camel@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On So, 2014-12-07 at 14:41 +0100, Hannes Frederic Sowa wrote:
> On So, 2014-12-07 at 08:30 -0500, George Spelvin wrote:
> > Thanks for the encouragement!
> > 
> > > Please consider xfs, too.
> > > AFAIK xfs doesn't seed their hashing so far and the hashing function is
> > > pretty weak. One example:
> > > http://marc.info/?l=linux-xfs&m=139590613002926&w=2
> > 
> > Is that something that *can* be changed without breaking the
> > disk format?  SipHash is explicitly *not* designed to be secure as
> > an unkeyed hash in the way that SHA-type algorithms are.
> 
> I did some research and it looked like it would need a change to the
> disk format but it should be doable by incrementing the super block
> version, so at least newly created filesystem would benefit from it.
> 
> > What it's designed to do is provide second preimage resistance
> > of its output, or a function (like modular reduction) of its output,
> > against an attacker who doesn't know the secret seed.
> > 
> > > Ack. If we want to use it in the networking stack we should be able to
> > > use it without a dependency to the crypto framework.
> > 
> > Already understood.  My big question is whether a single function call
> > is okay or we need something inlinable.
> 
> Like md5_transfrom, I think a non-inline function would be just fine.
> Otherwise kernel code size would increase. Most hash users in the
> network stack mostly deal with less bytes of input than one round needs.

Of course, if it looks feasable (from a performance PoV, but I doubt
that) to migrate the current jhash users to siphash, it might be worth
dealing with larger input sizes and maybe also doing it inline. But that
very much depends on the code size it would add. Currently we use jhash
as the non-linear "secure" hashing functions at most places.

Also rhashtable takes a pointer to the hasing function, thus causing gcc
to generate a function in each compilation unit if it would be static
inline.
