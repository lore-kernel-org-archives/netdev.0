From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: Endianness problem with u32 classifier hash masks
Date: Tue, 6 Nov 2007 15:25:58 +0100
Message-ID: <20071106142558.GC1666@ff.dom.local>
References: <20071105091231.GA1933@ff.dom.local> <1194267561.2987.141.camel@localhost.localdomain> <20071105135246.GB1933@ff.dom.local> <1194271589.4438.113.camel@localhost> <1194283888.2987.186.camel@localhost.localdomain> <472F85F0.8060205@o2.pl> <1194301667.4430.28.camel@localhost> <472FAF29.7050704@o2.pl> <1194336542.3305.33.camel@rad.rendec.ines.ro> <1194356071.4444.23.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Radu Rendec <radu.rendec@ines.ro>, netdev@vger.kernel.org
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:57037 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752056AbXKFOWL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Nov 2007 09:22:11 -0500
Content-Disposition: inline
In-Reply-To: <1194356071.4444.23.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 06, 2007 at 08:34:31AM -0500, jamal wrote:
> On Tue, 2007-06-11 at 10:09 +0200, Radu Rendec wrote:
>=20
> > Yup, you're right. Bitwise anding is the same regardless of the byt=
e
> > ordering of the operands. As long as you don't have one operand in =
host
> > order and the other in net order, it's ok.
>=20
> Ok
>=20
> > However, Jarek's computations with his mask and your patch seemed
> > correct to me yesterday. And I think I know the answer: data must b=
e
> > changed to host order _before_ shifting. I mean something like this=
:
> >=20
> > static __inline__ unsigned u32_hash_fold(u32 key, struct tc_u32_sel
> > *sel, u8 fshift)
> > {
> >        unsigned h =3D ntohl(key & sel->hmask) >> fshift;
> >        return h;
> > }
>=20
> Even better than what i suggested ;->

Yes, it saves one htonl() on the slow path!

>=20
> > > > On paper i get the same result with the new or old scheme for t=
he bucket selection.
> > > > As i stated on the patch - i never did test the theory.
> >=20
> > Well, neither did I (about what I stated above). But still I think,
> > Jarek was right yesterday and I can't figure out how it worked for =
you
> > on paper. How about this new version?
>=20
> Looks good - we can think of optimizing later.
>=20
> > Well, I think it's pretty clear now: I'll try my version of Jamal's
> > patch :)=20
>=20
> Which derived from your original patch using little effort in compari=
son
> to yours. All the hardwork is yours.
> You did quiet an impressive debug work. Please give yourself a little
> pat on the back for me.

Wait a minute! Don't forget to take a picture or something!

>=20
> > But not right now, because I also have to show up at work.
>=20
> I empathize.=20
> Please send two patches instead of one. One for this and the next for
> the ffs conversion (please run some simple tests in both cases).
>=20
> Jarek,
> Heres a few more derivations of Canada for you:
>=20
> Legend has it that Canada's name is derived from =20
> "settlement" in Iroquoian (One the First Nations in present day Canad=
a).
> I think it was pronounced "Kanata"
> An alternative legend says the early Spanish called it ac=E1nada  mea=
ning
> "nothing here"
>=20
> I tend to believe the Iroquoian version since to this day Canada
> continues to serve as a new settlement for many people. And the Spani=
sh
> were totaly wrong - there is something here ;-> At least Tim Hortons
> coffee.

Nice stories! Thanks. Btw, with this Polish saying, the strangest thing
is US was always preferred as a settlment, after all.

Regards,
Jarek P.
