From: Emil Goode <emilgoode@gmail.com>
Subject: Re: [PATCH 1/2 v2] usbnet: fix bad header length bug
Date: Mon, 10 Feb 2014 16:54:36 +0100
Message-ID: <20140210155436.GA4258@lianli>
References: <1391987174-21828-1-git-send-email-emilgoode@gmail.com>
 <1392014458.21271.6.camel@linux-fkkt.site>
 <20140210115812.GA4278@lianli>
 <1392034947.2082.30.camel@linux-fkkt.site>
 <87iosn86en.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oliver@neukum.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ming Lei <ming.lei@canonical.com>,
	Mark Brown <broonie@linaro.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Glen Turner <gdt@gdt.id.au>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org
To: =?utf-8?B?QmrDuHJu?= Mork <bjorn@mork.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87iosn86en.fsf@nemi.mork.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 10, 2014 at 02:05:20PM +0100, Bj=C3=B8rn Mork wrote:
> Oliver Neukum <oliver@neukum.org> writes:
> > On Mon, 2014-02-10 at 13:00 +0100, Emil Goode wrote:
> >> On Mon, Feb 10, 2014 at 07:40:58AM +0100, Oliver Neukum wrote:
> >
> >> > Well, then how about simply removing the check?
> >> > It seems to have outlived its usefulness.
> >> >=20
> >> > 	Regards
> >> > 		Oliver
> >> >=20
> >> >
> >>=20
> >> I did consider that and I think it is probably the best thing to d=
o.
> >> However, I think the removal of the check could have negative effe=
cts
> >> on the other minidrivers, at least the qmi_wwan minidriver explici=
tly
> >> states that it is depending on this check to be made in rx_complet=
e().
> >
> > <censored>.
>=20
> No need to do that.  I had the exact same reaction myself :-)
>=20
> Anyway, I put that comment there mostly as a note to myself why the
> check would be redundant at that point.  I don't see any problem with
> removing the generic check in usbnet as long as we add similar checks
> whereever they are needed, like in qmi_wwan.

I think it could be worth the trouble of removing the generic check in
the usbnet module.

I believe that if you define your own rx_fixup callback then the
usbnet module should not make it's own assumptions on what packets=20
to discard.

Since the checks that need to be added in various places are all in
the same subsystem I think it could be done in as little as one patch?

> Note that usbnet_skb_return will be one of those places.  It calls
> eth_type_trans() on the skb, so it should verify that the length is a=
t
> least ETH_HLEN first.
>=20
> > Oh well. But how about merging it with FLAG_MULTI_PACKET?
> > I really don't want to add more flags. There is a point where enoug=
h
> > flags make absurd having a common code. We are closing in on that p=
oint.
>=20
> Agreed.  I would even say we are past that point...

If nobody have any objections I will try removing the generic check and
introduce checks where nessecary.

Best regards,

Emil Goode
