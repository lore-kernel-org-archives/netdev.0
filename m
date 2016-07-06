From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 00/10] NCSI Support
Date: Tue, 5 Jul 2016 19:07:33 -0700
Message-ID: <20160706020731.GA82573@ast-mbp>
References: <1467523953-18998-1-git-send-email-gwshan@linux.vnet.ibm.com>
 <CAJ3xEMjEup1VUeCr3g2Ry78HvprfnC6wjGd=MWjnMOLWdLyKdQ@mail.gmail.com>
 <20160705174433.GA73415@ast-mbp.thefacebook.com>
 <1467754959.13965.66.camel@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
	Gavin Shan <gwshan@linux.vnet.ibm.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, joel@jms.id.au,
	weixue@trustnetic.com, yuvali@mellanox.com
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:33113 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751930AbcGFCHi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 22:07:38 -0400
Received: by mail-pa0-f68.google.com with SMTP id ts6so19790968pac.0
        for <netdev@vger.kernel.org>; Tue, 05 Jul 2016 19:07:38 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1467754959.13965.66.camel@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 06, 2016 at 07:42:39AM +1000, Benjamin Herrenschmidt wrote:
> On Tue, 2016-07-05 at 10:44 -0700, Alexei Starovoitov wrote:
> >=20
>=20
> =A0.../...
>=20
> > > > The design for the patchset is highlighted as below:
> > > >=20
> > > > =A0=A0=A0* The NCSI interface is abstracted with "struct ncsi_d=
ev". It's registered
> > > > =A0=A0=A0=A0=A0when net_device is created, started to work by c=
alling ncsi_start_dev()
> > > > =A0=A0=A0=A0=A0when net_device is opened (ndo_open()). For the =
first time, NCSI packets
> > > > =A0=A0=A0=A0=A0are sent and received to/from the far end (host =
in above figure) to probe
> > > > =A0=A0=A0=A0=A0available NCSI packages and channels. After that=
, one channel is chosen as
> > > > =A0=A0=A0=A0=A0active one to provide service.
> > > > =A0=A0=A0* The NCSI stack is driven by workqueue and state mach=
ine internally.
> > > > =A0=A0=A0* AEN (Asychronous Event Notification) might be receiv=
ed from the far end
> > > > =A0=A0=A0=A0=A0(host). The currently active NCSI channel fails =
over to another available
> > > > =A0=A0=A0=A0=A0one if possible. Otherwise, the NCSI channel is =
out of service.
> > > > =A0=A0=A0* NCSI stack should be configurable through netlink or=
 another mechanism,
> > > > =A0=A0=A0=A0=A0but it's not implemented in this patchset. It's =
something TBD.
> >=20
> > Gavin,
> > what configurations do you have in mind?
> > For ncsi itself or to control the nic on the host?
> > This set of patches is for BMC side, right?
> > What needs to be done on the host?
>=20
> I'll respond for Gavin since I'm awake first ;-)
>=20
> We use that stack today on OpenBMC on some OpenPOWER machines.
>=20
> The configuration is thus for the above stack to run on the BMC in
> order to control the host NIC.
>=20
> NC-SI capable host NICs operate autonomously, so there is nothing to =
be
> done on the host OS itself, at least not with the BCM NICs that we us=
e
> today, but of course the host NIC firmware needs to have the other si=
de
> of the stack.

Great! Thanks for clarifying.
So then future netlink api is mandatory to drive this kernel patches?
How one can use this set without it?
What is the main reason for this infra to be in the kernel instead of
userspace raw socket? Some interaction with the driver, right?
but it's not obvious from the patches.
