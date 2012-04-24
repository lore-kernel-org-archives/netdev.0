From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: [RFC v4] Add TCP encap_rcv hook (repost)
Date: Mon, 23 Apr 2012 21:40:57 -0700 (PDT)
Message-ID: <2a718516-6883-4a46-b5e2-1c73be2b4b59@tahiti.vyatta.com>
References: <20120424022514.GB5357@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, jhs@mojatatu.com,
	netdev@vger.kernel.org, dev@openvswitch.org,
	eric dumazet <eric.dumazet@gmail.com>,
	Kyle Mestery <kmestery@cisco.com>,
	Jesse Gross <jesse@nicira.com>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:38885 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751064Ab2DXEk7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2012 00:40:59 -0400
In-Reply-To: <20120424022514.GB5357@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



----- Original Message -----
> On Mon, Apr 23, 2012 at 03:59:24PM -0700, Jesse Gross wrote:
> > On Mon, Apr 23, 2012 at 3:32 PM, Simon Horman <horms@verge.net.au>
> > wrote:
> > > On Mon, Apr 23, 2012 at 02:38:07PM -0700, Jesse Gross wrote:
> > >> On Mon, Apr 23, 2012 at 2:08 PM, David Miller
> > >> <davem@davemloft.net> wrote:
> > >> > From: Jesse Gross <jesse@nicira.com>
> > >> > Date: Mon, 23 Apr 2012 13:53:42 -0700
> > >> >
> > >> >> On Mon, Apr 23, 2012 at 1:13 PM, David Miller
> > >> >> <davem@davemloft.net> wrote:
> > >> >>> From: Jesse Gross <jesse@nicira.com>
> > >> >>> Date: Mon, 23 Apr 2012 13:08:49 -0700
> > >> >>>
> > >> >>>> Assuming that the TCP stack generates large TSO frames on
> > >> >>>> transmit
> > >> >>>> (which could be the local stack; something sent by a VM; or
> > >> >>>> packets
> > >> >>>> received, coalesced by GRO and then encapsulated by STT)
> > >> >>>> then you can
> > >> >>>> just prepend the STT header (possibly slightly adjusting
> > >> >>>> things like
> > >> >>>> requested MSS, number of segments, etc. slightly). =C2=A0Af=
ter
> > >> >>>> that it's
> > >> >>>> possible to just output the resulting frame through the IP
> > >> >>>> stack like
> > >> >>>> all tunnels do today.
> > >> >>>
> > >> >>> Which seems to potentially suggest a stronger intergration
> > >> >>> of the STT
> > >> >>> tunnel transmit path into our IP stack rather than the
> > >> >>> approach Simon
> > >> >>> is taking
> > >> >>
> > >> >> Did you have something in mind?
> > >> >
> > >> > A normal bonafide tunnel netdevice driver like GRE instead of
> > >> > the
> > >> > openvswitch approach Simon is using.
> > >>
> > >> Ahh, yes, that I agree with. =C2=A0Independent of this, there's =
work
> > >> being
> > >> done to make it so that OVS can use the normal in-tree tunneling
> > >> code
> > >> and not need its own. =C2=A0Once that's done I expect that STT w=
ill
> > >> follow
> > >> the same model.
> > >
> > > Hi Jesse,
> > >
> > > I am wondering how firm the plans to on allowing OVS to use
> > > in-tree tunnel
> > > code are. I'm happy to move my efforts over to an in-tree STT
> > > implementation
> > > but ultimately I would like to get STT running in conjunction
> > > with OVS.
> >=20
> > I would say that it's a firm goal but the implementation probably
> > still has a ways to go.  Kyle Mestery (CC'ed) has volunteered to
> > work
> > on this in support of adding VXLAN, which needs some additional
> > flexibility that this approach would also provide.  You might want
> > to
> > talk to him to see if there are ways that you guys can work
> > together
> > on it if you are interested.  Having better integration with
> > upstream
> > tunneling is definitely a step that OVS needs to make and sooner
> > would
> > be better than later.
>=20
> Hi Jesse, Hi Kyle,
>=20
> that sounds like an excellent plan.
>=20
> Kyle, do you have any thoughts on how we might best work together on
> this?
> Perhaps there are some patches floating around that I could take a
> look at?

ChrisW had a start to VxVlan tunnel (non OVS), and I promised to work o=
n finishing
it.
