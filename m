From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Regression: Recent networking (qdisc?) patches break
 irda_get_next_speed()
Date: Thu, 23 Oct 2008 16:16:41 -0700
Message-ID: <20081023161641.0d4f714d@extreme>
References: <48FE1D52.6080903@ceibo.fiec.espol.edu.ec>
	<48FE2F81.9060801@gmail.com>
	<48FE67D4.5060200@ceibo.fiec.espol.edu.ec>
	<20081021.164121.257737412.davem@davemloft.net>
	<48FFC438.1080505@ceibo.fiec.espol.edu.ec>
	<F169D4F5E1F1974DBFAFABF47F60C10A069DFD1F@orsmsx507.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alex =?UTF-8?B?VmlsbGFjw63CrXM=?= Lasso
	<avillaci@ceibo.fiec.espol.edu.ec>,
	"irda-users@lists.sourceforge.net" <irda-users@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34919 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751910AbYJWXQq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2008 19:16:46 -0400
In-Reply-To: <F169D4F5E1F1974DBFAFABF47F60C10A069DFD1F@orsmsx507.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 23 Oct 2008 15:13:02 -0700
"Brandeburg, Jesse" <jesse.brandeburg@intel.com> wrote:

> Alex Villac=C3=AD=C2=ADs Lasso wrote:
> <snip>
>=20
> >> The SKB control block is not aliased.
> >>=20
>=20
> ...
> >> IRDA cannot depend upon the SKB control block not changing across
> >> the dev_queue_xmit() call.=20
> >>=20
> >>=20
> > Let me see if I understood. So the particular illegal thing the IRD=
A
> > stack is doing is the access of the control block in the middle of =
the
> > driver transmit routine (via irda_get_next_speed() and friends). Th=
is
> > information should be stored somewhere else. Exactly *where* to sto=
re
> > it is the main problem to solve.
> >=20
> > What is the proper way (if any) to store per-packet parameters (oth=
er
> > than the payload itself) which are specific to a particular layer
> > (IrDA in this case) and which are needed by drivers in order to wor=
k
> > correctly? The control block gets overwritten by the time the drive=
r
> > proc (hard_start_xmit) is called, so this approach is now ruled out=
=2E I
> > was thinking about storing a copy of the parameters (struct
> > irda_skb_cb) as a header within the payload itself (skb->data[]), b=
ut
> > I am not sure about whether this approach is a good design decision=
=2E
> > I am open to suggestions on where to place the parameters.
>=20
> Isn't this what the data that is skb_reserve'd at the beginning of sk=
b's allocated by netdev_alloc_skb is for?  If you take an extra referen=
ce to the skb and/or use a destructor hook you should be good, right?
>=20
> you should just be able to push ->data using skb_reserve(sizeof your =
private data) in the beginning of the skb, or is that a horrible idea D=
ave?

That space is reserved for a copy of the ethernet header when doing bri=
dge/filtering.
Yes, its a stupid, undocumented hack.=20

If irda needs additional protocol space, it could advertise a larger ha=
rdware header
size and use the additional space for hidden protocol info.=20
