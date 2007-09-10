From: Denys Vlasenko <vda.linux@googlemail.com>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Mon, 10 Sep 2007 11:56:29 +0100
Message-ID: <200709101156.30010.vda.linux@googlemail.com>
References: <18115.52863.638655.658466@cargo.ozlabs.ibm.com> <200709091902.55388.vda.linux@googlemail.com> <20070909191839.1fa10e88@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Nick Piggin <piggin@cyberone.com.au>,
	Satyam Sharma <satyam@infradead.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Paul Mackerras <paulus@samba.org>,
	Christoph Lameter <clameter@sgi.com>,
	Chris Snook <csnook@redhat.com>,
	Ilpo Jarvinen <ilpo.jarvinen@helsinki.fi>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-arch@vger.kernel.org, Netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>, ak@suse.de,
	heiko.carstens@de.ibm.com, David Miller <davem@davemloft.net>,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org,
	rpjday@mindspring.com, jesper.juhl@gmail.com,
	segher@kernel.crashing.org
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932728AbXIJK5A@vger.kernel.org>
In-Reply-To: <20070909191839.1fa10e88@laptopd505.fenrus.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 09 September 2007 19:18, Arjan van de Ven wrote:
> On Sun, 9 Sep 2007 19:02:54 +0100
> Denys Vlasenko <vda.linux@googlemail.com> wrote:
>=20
> > Why is all this fixation on "volatile"? I don't think
> > people want "volatile" keyword per se, they want atomic_read(&x) to
> > _always_ compile into an memory-accessing instruction, not register
> > access.
>=20
> and ... why is that?
> is there any valid, non-buggy code sequence that makes that a
> reasonable requirement?

Well, if you insist on having it again:

Waiting for atomic value to be zero:

=A0=A0=A0=A0=A0=A0=A0=A0while (atomic_read(&x))
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0continue;

gcc may happily convert it into:

        reg =3D atomic_read(&x);
        while (reg)
                continue;

Expecting every driver writer to remember that atomic_read is not in fa=
ct
a "read from memory" is naive. That won't happen. Face it, majority of
driver authors are a bit less talented than Ingo Molnar or Arjan van de=
 Ven ;)
The name of the macro is saying that it's a read.
We are confusing users here.

It's doubly confusing that cpy_relax(), which says _nothing_ about barr=
iers
in its name, is actually a barrier you need to insert here.
--
vda
