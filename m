From: Felipe Balbi <felipe.balbi@linux.intel.com>
Subject: Re: [PATCH] Revert "usb: dwc3: gadget: use allocated/queued reqs for LST bit"
Date: Fri, 28 Oct 2016 13:16:13 +0300
Message-ID: <87pomksrrm.fsf@linux.intel.com>
References: <1475504282-13268-1-git-send-email-ville.syrjala@linux.intel.com> <87lgy5za7o.fsf@linux.intel.com> <20161004083855.GW4329@intel.com> <8760p8qp5b.fsf@linux.intel.com> <20161004132059.GX4329@intel.com> <87mvikp5wx.fsf@linux.intel.com> <87shsand3q.fsf@linux.intel.com> <20161006090826.GH4329@intel.com> <20161027154016.GD4617@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Cc: linux-usb@vger.kernel.org, stable@vger.kernel.org,
        davem@davemloft.net, Oliver Neukum <oneukum@suse.com>,
        netdev@vger.kernel.org
To: Ville =?utf-8?B?U3lyasOkbMOk?= <ville.syrjala@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:47174 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755671AbcJ1KQf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 28 Oct 2016 06:16:35 -0400
In-Reply-To: <20161027154016.GD4617@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


Hi,

Ville Syrj=C3=A4l=C3=A4 <ville.syrjala@linux.intel.com> writes:
> On Thu, Oct 06, 2016 at 12:08:26PM +0300, Ville Syrj=C3=A4l=C3=A4 wrote:
>> On Thu, Oct 06, 2016 at 10:36:09AM +0300, Felipe Balbi wrote:
>> >=20
>> > Hi,
>> >=20
>> > Felipe Balbi <felipe.balbi@linux.intel.com> writes:
>> <snip>
>> > Okay, I have found a regression on dwc3 and another patch follows:
>> >=20
>> > commit 5e1a2af3e46248c55098cdae643c4141851b703e
>> > Author: Felipe Balbi <felipe.balbi@linux.intel.com>
>> > Date:   Wed Oct 5 14:24:37 2016 +0300
>> >=20
>> >     usb: dwc3: gadget: properly account queued requests
>> >=20=20=20=20=20
>> >     Some requests could be accounted for multiple
>> >     times. Let's fix that so each and every requests is
>> >     accounted for only once.
>> >=20=20=20=20=20
>> >     Cc: <stable@vger.kernel.org> # v4.8
>> >     Fixes: 55a0237f8f47 ("usb: dwc3: gadget: use allocated/queued reqs=
 for LST bit")
>> >     Signed-off-by: Felipe Balbi <felipe.balbi@linux.intel.com>
>> >=20
>> > diff --git a/drivers/usb/dwc3/gadget.c b/drivers/usb/dwc3/gadget.c
>> > index 07cc8929f271..3c3ced128c77 100644
>> > --- a/drivers/usb/dwc3/gadget.c
>> > +++ b/drivers/usb/dwc3/gadget.c
>> > @@ -783,6 +783,7 @@ static void dwc3_prepare_one_trb(struct dwc3_ep *d=
ep,
>> >  		req->trb =3D trb;
>> >  		req->trb_dma =3D dwc3_trb_dma_offset(dep, trb);
>> >  		req->first_trb_index =3D dep->trb_enqueue;
>> > +		dep->queued_requests++;
>> >  	}
>> >=20=20
>> >  	dwc3_ep_inc_enq(dep);
>> > @@ -833,8 +834,6 @@ static void dwc3_prepare_one_trb(struct dwc3_ep *d=
ep,
>> >=20=20
>> >  	trb->ctrl |=3D DWC3_TRB_CTRL_HWO;
>> >=20=20
>> > -	dep->queued_requests++;
>> > -
>> >  	trace_dwc3_prepare_trb(dep, trb);
>> >  }
>> >=20=20
>> > @@ -1861,8 +1860,11 @@ static int __dwc3_cleanup_done_trbs(struct dwc3=
 *dwc, struct dwc3_ep *dep,
>> >  	unsigned int		s_pkt =3D 0;
>> >  	unsigned int		trb_status;
>> >=20=20
>> > -	dep->queued_requests--;
>> >  	dwc3_ep_inc_deq(dep);
>> > +
>> > +	if (req->trb =3D=3D trb)
>> > +		dep->queued_requests--;
>> > +
>> >  	trace_dwc3_complete_trb(dep, trb);
>> >=20=20
>> >  	/*
>> >=20
>> > I have also built a branch which you can use for testing. Here's a pull
>> > request, once you tell me it works for you, then I can send proper
>> > patches out:
>> >=20
>> > The following changes since commit c8d2bc9bc39ebea8437fd974fdbc21847bb=
897a3:
>> >=20
>> >   Linux 4.8 (2016-10-02 16:24:33 -0700)
>> >=20
>> > are available in the git repository at:
>> >=20
>> >   git://git.kernel.org/pub/scm/linux/kernel/git/balbi/usb.git tmp-test=
-v4.8
>> >=20
>> > for you to fetch changes up to c968b8d1effe64a7980802d1eef29f4e1922fac=
a:
>> >=20
>> >   usb: dwc3: gadget: properly account queued requests (2016-10-06 10:1=
6:37 +0300)
>> >=20
>> > ----------------------------------------------------------------
>> > Felipe Balbi (2):
>> >       usb: gadget: function: u_ether: don't starve tx request queue
>> >       usb: dwc3: gadget: properly account queued requests
>> >=20
>> >  drivers/usb/dwc3/gadget.c             | 7 ++++---
>> >  drivers/usb/gadget/function/u_ether.c | 5 +++--
>> >  2 files changed, 7 insertions(+), 5 deletions(-)
>>=20
>> Tried your branch, but unfortunately I'm still seeing the lags. New trace
>> attached.
>
> Just a reminder that the regressions is still there in 4.9-rc2.
> Unfortunateyly with all the stuff already piled on top, getting USB
> working on my device is no longer a simple matter of reverting the
> one commit. I had to revert 10 patches to get even a clean revert, but
> unfortunately that approach just lead to the transfer hanging immediately.
>
> So what I ended up doing is reverting all of this:
> git log --no-merges --format=3Doneline 55a0237f8f47957163125e20ee9260538c=
5c341c^..HEAD -- drivers/usb/dwc3/ include/linux/ulpi/interface.h drivers/u=
sb/Kconfig drivers/usb/core/Kconfig
>
> which comes out at whopping 70 commits. Having to carry that around
> is going to be quite a pain especially as more stuff might be piled on
> top.
>
> /me thinks a stable backport of any fix (assuming one is found
> eventually) is going to be quite the challenge...

Yeah, I'm guessing we're gonna need some help from networking folks. The
only thing we did since v4.7 was actually respect req->no_interrupt flag
coming from u_ether itself. No idea why that causes so much trouble for
u_ether.

BTW, Instead of reverting so many patches, you can just remove
throttling:

diff --git a/drivers/usb/gadget/function/u_ether.c b/drivers/usb/gadget/fun=
ction/u_ether.c
index f4a640216913..119a2e5848e8 100644
=2D-- a/drivers/usb/gadget/function/u_ether.c
+++ b/drivers/usb/gadget/function/u_ether.c
@@ -589,14 +589,6 @@ static netdev_tx_t eth_start_xmit(struct sk_buff *skb,
=20
        req->length =3D length;
=20
=2D       /* throttle high/super speed IRQ rate back slightly */
=2D       if (gadget_is_dualspeed(dev->gadget))
=2D               req->no_interrupt =3D (((dev->gadget->speed =3D=3D USB_SP=
EED_HIGH ||
=2D                                      dev->gadget->speed =3D=3D USB_SPEE=
D_SUPER)) &&
=2D                                       !list_empty(&dev->tx_reqs))
=2D                       ? ((atomic_read(&dev->tx_qlen) % dev->qmult) !=3D=
 0)
=2D                       : 0;
=2D
        retval =3D usb_ep_queue(in, req, GFP_ATOMIC);
        switch (retval) {
        default:

I'm adding netdev and couple other folks to the loop.

Just to summarize, USB peripheral controller now actually throttles
interrupt when requested to do so and that causes lags for USB
networking gadgets.

Without throttle we, potentially, call netif_wake_queue() more
frequently than with throttling. I'm wondering if something changed in
NET layer within the past few years but the USB networking gadgets ended
up being forgotten.

Anyway, if anybody has any hints, I'd be glad to hear about them.

=2D-=20
balbi

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJYEyVtAAoJEMy+uJnhGpkGDu0P/RhaAoeeTJrnO8zrBtrFa+I1
FBuD4eqPMqVii2pNi1tM4rYrhreq55Ika/94NR8OpWMv4FF0fsRfQQeMpYc1VVSh
USZrUXLKC29vMia9lXohGVKRa08PttVth2vSc/o/g6FQTRDbg85/6gdCHTp959Ec
OR1xPYMhb9EhbhhoNQE8OMCDXQsxia6L6fohDmfCTSKSEUWxGllwfh+owrLF/2jI
2g+BNaRHyS9ioizugpQofg7KttR4WHtQTr8Wr303v2yHmsvz9Uk1krwtRpaTm4Oz
Zh3Wn6DbFPi6PNJv5/mPR2ioIg9XiHX20cJj6fI/7XXUVlWFrzmmKRJdBmxrSb/d
trROnm9DMEycrm5Nl1o9R8QKsiJaY7H6GB5EJhSfBrlv9mHB8DDEii3OfOl6DtTW
kFJOUeUv8DJTwes+wCvLa/YSNsHqTkagEh/77yIKO/3JwzcJKzloUwn96UheZ83A
gC/Wv99dWzSg9k9ZaMtOFAB2fvCT3phvnDVIil3pSnSFbFoS0NJcO3FWo5mcKwnX
aXiZ4Y9nb+6pNMjUG7M8WRsuOHebUjTaCz7jzUcuZ2VVI+cyRRPus7XJ9eSq3275
v9SXCXNdCxZmQFhwu3RiMrh8hUSiAJxNgnpKn+fxPSVoSzant7CmWA7IND3sPyDR
RMbdsmH1byCpxx98Lhya
=uZ0h
-----END PGP SIGNATURE-----
--=-=-=--
