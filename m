From: jamal <hadi@cyberus.ca>
Subject: Re: Endianness problem with u32 classifier hash masks
Date: Tue, 06 Nov 2007 08:34:31 -0500
Message-ID: <1194356071.4444.23.camel@localhost>
References: <1193939701.2987.82.camel@localhost.localdomain>
	 <472B5EF1.4020206@o2.pl> <1194045830.4438.21.camel@localhost>
	 <472D06B2.9040402@o2.pl> <472D0B1C.7000209@o2.pl> <472D128B.8030704@o2.pl>
	 <472D1DC2.9000106@o2.pl> <1194220693.4438.75.camel@localhost>
	 <20071105091231.GA1933@ff.dom.local>
	 <1194267561.2987.141.camel@localhost.localdomain>
	 <20071105135246.GB1933@ff.dom.local> <1194271589.4438.113.camel@localhost>
	 <1194283888.2987.186.camel@localhost.localdomain> <472F85F0.8060205@o2.pl>
	 <1194301667.4430.28.camel@localhost> <472FAF29.7050704@o2.pl>
	 <1194336542.3305.33.camel@rad.rendec.ines.ro>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@o2.pl>, netdev@vger.kernel.org
To: Radu Rendec <radu.rendec@ines.ro>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.181]:13688 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752559AbXKFNeh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2007 08:34:37 -0500
Received: by wa-out-1112.google.com with SMTP id v27so2402853wah
        for <netdev@vger.kernel.org>; Tue, 06 Nov 2007 05:34:37 -0800 (PST)
In-Reply-To: <1194336542.3305.33.camel@rad.rendec.ines.ro>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-06-11 at 10:09 +0200, Radu Rendec wrote:

> Yup, you're right. Bitwise anding is the same regardless of the byte
> ordering of the operands. As long as you don't have one operand in ho=
st
> order and the other in net order, it's ok.

Ok

> However, Jarek's computations with his mask and your patch seemed
> correct to me yesterday. And I think I know the answer: data must be
> changed to host order _before_ shifting. I mean something like this:
>=20
> static __inline__ unsigned u32_hash_fold(u32 key, struct tc_u32_sel
> *sel, u8 fshift)
> {
>        unsigned h =3D ntohl(key & sel->hmask) >> fshift;
>        return h;
> }

Even better than what i suggested ;->

> > > On paper i get the same result with the new or old scheme for the=
 bucket selection.
> > > As i stated on the patch - i never did test the theory.
>=20
> Well, neither did I (about what I stated above). But still I think,
> Jarek was right yesterday and I can't figure out how it worked for yo=
u
> on paper. How about this new version?

Looks good - we can think of optimizing later.

> Well, I think it's pretty clear now: I'll try my version of Jamal's
> patch :)=20

Which derived from your original patch using little effort in compariso=
n
to yours. All the hardwork is yours.
You did quiet an impressive debug work. Please give yourself a little
pat on the back for me.

> But not right now, because I also have to show up at work.

I empathize.=20
Please send two patches instead of one. One for this and the next for
the ffs conversion (please run some simple tests in both cases).

Jarek,
Heres a few more derivations of Canada for you:

Legend has it that Canada's name is derived from =20
"settlement" in Iroquoian (One the First Nations in present day Canada)=
=2E
I think it was pronounced "Kanata"
An alternative legend says the early Spanish called it ac=E1nada  meani=
ng
"nothing here"

I tend to believe the Iroquoian version since to this day Canada
continues to serve as a new settlement for many people. And the Spanish
were totaly wrong - there is something here ;-> At least Tim Hortons
coffee.

cheers,
jamal

