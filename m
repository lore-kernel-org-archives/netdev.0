From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH net-next 00/10] NCSI Support
Date: Wed, 06 Jul 2016 07:42:39 +1000
Message-ID: <1467754959.13965.66.camel@kernel.crashing.org>
References: <1467523953-18998-1-git-send-email-gwshan@linux.vnet.ibm.com>
	 <CAJ3xEMjEup1VUeCr3g2Ry78HvprfnC6wjGd=MWjnMOLWdLyKdQ@mail.gmail.com>
	 <20160705174433.GA73415@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Gavin Shan <gwshan@linux.vnet.ibm.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, joel@jms.id.au,
	weixue@trustnetic.com, yuvali@mellanox.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:35368 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755496AbcGEVnI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jul 2016 17:43:08 -0400
In-Reply-To: <20160705174433.GA73415@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-07-05 at 10:44 -0700, Alexei Starovoitov wrote:
>=20

=C2=A0.../...

> > > The design for the patchset is highlighted as below:
> > >=20
> > > =C2=A0=C2=A0=C2=A0* The NCSI interface is abstracted with "struct=
 ncsi_dev". It's registered
> > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0when net_device is created, started=
 to work by calling ncsi_start_dev()
> > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0when net_device is opened (ndo_open=
()). For the first time, NCSI packets
> > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0are sent and received to/from the f=
ar end (host in above figure) to probe
> > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0available NCSI packages and channel=
s. After that, one channel is chosen as
> > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0active one to provide service.
> > > =C2=A0=C2=A0=C2=A0* The NCSI stack is driven by workqueue and sta=
te machine internally.
> > > =C2=A0=C2=A0=C2=A0* AEN (Asychronous Event Notification) might be=
 received from the far end
> > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0(host). The currently active NCSI c=
hannel fails over to another available
> > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0one if possible. Otherwise, the NCS=
I channel is out of service.
> > > =C2=A0=C2=A0=C2=A0* NCSI stack should be configurable through net=
link or another mechanism,
> > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0but it's not implemented in this pa=
tchset. It's something TBD.
>=20
> Gavin,
> what configurations do you have in mind?
> For ncsi itself or to control the nic on the host?
> This set of patches is for BMC side, right?
> What needs to be done on the host?

I'll respond for Gavin since I'm awake first ;-)

We use that stack today on OpenBMC on some OpenPOWER machines.

The configuration is thus for the above stack to run on the BMC in
order to control the host NIC.

NC-SI capable host NICs operate autonomously, so there is nothing to be
done on the host OS itself, at least not with the BCM NICs that we use
today, but of course the host NIC firmware needs to have the other side
of the stack.

> > > =C2=A0=C2=A0=C2=A0* The first NIC driver that is aware of NCSI: d=
rivers/net/ethernet/faraday/ftgmac100.c
> >=20
> >=20
> > FWIW, talking to a colleague, he made a comment that some of the te=
xt
> > above is wrong:
> >=20
> > AENs are sent from NIC to BMC. Not from Host to BMC.
> >=20
> > The traffic between a BMC and a NIC is over RBT if it is formatted =
as
> > NC-SI packets. This is not over network traffic....
> >=20
> > Or.
>=20
> Or,
> since cx4 has ncsi as well, could you do a thorough review of this
> to make sure that it fits mellanox nics as well?

Cheers,
Ben.
