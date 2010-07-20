From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: net/dsa
Date: Tue, 20 Jul 2010 23:54:18 +0200
Message-ID: <20100720215417.GF21121@mail.wantstofly.org>
References: <4C3B8231.6020706@gmail.com> <20100720135950.GZ14513@mail.wantstofly.org> <AANLkTinBA3uqfML78PRr1-xN2ye_3Pjj-NQE5t7eHxGy@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Karl Beldan <karl.beldan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wantstofly.org ([80.101.37.227]:48358 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753943Ab0GTVyV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jul 2010 17:54:21 -0400
Content-Disposition: inline
In-Reply-To: <AANLkTinBA3uqfML78PRr1-xN2ye_3Pjj-NQE5t7eHxGy@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 20, 2010 at 11:28:19PM +0200, Karl Beldan wrote:

> >> I found the dsa code very handy to help manage a switch.
> >
> > Ah. =A0What particular part are you using?
>=20
> The whole thing but the cascading stuff.
> I could even reuse a tagging format almost as is!

I meant, which silicon part, i.e. which hardware/chips?  Anything with
available data sheets?


> >> Yet I was surprised I had to tweak the code to simply use the phy
> >> layer state machine.
> >
> > You mean that net/dsa uses phy_attach() but not phy_start_machine()=
 ?
> > Have you seen problems arising from this?
>
> I did not mean that, but I do not think there would be a problem,
> since every in-tree driver provide their poll_link() to do the job of
> the phylib's state_queue, unless one does not provide its poll_link()=
,
> I guess this is what you had in mind.
> What I had in mind in fact was the re-use of the phylib's interrupt
> based code, in this situation poll_link() is not there, but there
> replacing phy_attach() with phy_start_machine is not enough.

We cannot rely on the switch's interrupt pin being hooked up -- there
are many boards out where it's not wired up at all.  Therefore, polling
for link state changes is the only reliable and portable way.

(Of course, interrupt support can always be added, and that used
instead of polling if a load-time test shows that the interrupt pin
actually works.)


> Those are not big changes, but the code seems to aim at such versatil=
e
> behavior (and more), I can only imagine it would be useful for the
> plethora of boards embedding a switch.

Although it supports Marvell chips only for now, net/dsa was written to
be able to handle other models of switch chips as well.  As I said, I
would love to see support for other switch chips added to it.


> > > So I was wondering if there was anybody playing with this code, o=
r
> > > having ideas about features to add (vlan/stp callbacks) ?
> >
> > As far as I know, the code currently in the kernel works well for w=
hat
> > it intends to do (which is to just expose the switch ports), and I'=
m
> > not aware of any bugs in it.
> >
> > That said, you're right in that there are several more features tha=
t
> > the hardware supports that the software could be extended to handle=
=2E
> >
> > For one, I don't have access to any Marvell switch chip hardware
> > anymore, so that limits my ability to play with this. =A0Also, the
> > relevant documentation is under a rather restrictive license, so th=
e
> > only way I can see net/dsa support for Marvell parts improving is i=
f
> > there's pressure from a large enough customer to make this happen.
>
> Now I understand, but still, I am surprised nobody else touched the
> code, with all those switches in the embedded business.

Me too..

=2E.then again, "embedded people" tend to hack up stuff in private
and ship whatever works -- they aren't exactly known for working with
upstream.
