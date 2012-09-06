From: Oliver Neukum <oneukum@suse.de>
Subject: Re: changing usbnet's API to better deal with cdc-ncm
Date: Thu, 06 Sep 2012 19:56:50 +0200
Message-ID: <1676538.CEPj2RtrPe@linux-lqwf.site>
References: <2791550.LhGu6po6Xy@linux-lqwf.site> <87a9x33656.fsf@nemi.mork.no> <CACVXFVMYmTFLamWzTL2gTtu31eQg6bpLA4NapJehPoROF4t3dw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>,
	alexey.orishko@stericsson.com, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:35944 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932609Ab2IFR6M convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2012 13:58:12 -0400
In-Reply-To: <CACVXFVMYmTFLamWzTL2gTtu31eQg6bpLA4NapJehPoROF4t3dw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 07 September 2012 00:09:13 Ming Lei wrote:
> On Thu, Sep 6, 2012 at 4:30 PM, Bj=F8rn Mork <bjorn@mork.no> wrote:
> > Ming Lei <tom.leiming@gmail.com> writes:

> >> Looks the introduced .tx_bundle is not necessary since .tx_fixup i=
s OK.
> >
> > The minidriver does not have any information about tx in progress. =
 The
>=20
> Inside .tx_fixup, the low level driver will get the tx progress infor=
mation.

That information changes after tx_fixup
=20
> > strategy above, which is what cdc_ncm uses today, is fine as long a=
s you
> > always want to wait as long as you always want to fill as many fram=
es as
> > possible in each packet.  But what if the queue is empty and the de=
vice
>=20
> For cdc_ncm, the wait time is controlled by cdc_ncm driver, see
> cdc_ncm_tx_timeout_start().

Well, that is the mistake. Using a timer is a bad idea.

> If we can abstract some common things about aggregation, it should be
> meaningful. As far as I know, most of aggregation protocol is very di=
fferent,
> so almost all aggregation work is only done by low level driver, such=
 as
> cdc_ncm.
>=20
> If we want to implement some aggregation framework, maybe below is
> one solution, correct me if it is wrong.

It isn't so much wrong as incomplete.

It seems to me we can have

- can queue, buffer not full -> do nothing more
- can queue, buffer full -> transmit
- cannot queue, buffer full -> transmit and then try again to queue

and an error case

- cannot queue, buffer not full

And that's the way I coded it.

	Regards
		Oliver
