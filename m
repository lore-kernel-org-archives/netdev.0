From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH v2 46/46] net: mark drivers that drop packets from rx
 queue head under memory pressure
Date: Mon, 11 Jul 2011 12:04:47 +0200
Message-ID: <20110711100447.GA7532@rere.qmqm.pl>
References: <cover.1310339688.git.mirq-linux@rere.qmqm.pl>
 <c84a04a957128ae664f4a80da23fad4b9f71a85f.1310339689.git.mirq-linux@rere.qmqm.pl>
 <1310366828.22731.1.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Hartley Sweeten <hsweeten@visionengravers.com>,
	Michael Chan <mchan@broadcom.com>,
	Guo-Fu Tseng <cooldavid@cooldavid.org>,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Matthew Carlson <mcarlson@broadcom.com>,
	Jon Mason <jdmason@kudzu.us>
To: Eilon Greenstein <eilong@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:38168 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753098Ab1GKKEs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jul 2011 06:04:48 -0400
Content-Disposition: inline
In-Reply-To: <1310366828.22731.1.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 11, 2011 at 09:47:08AM +0300, Eilon Greenstein wrote:
> On Sun, 2011-07-10 at 17:52 -0700, Micha=B3 Miros=B3aw wrote:
> > Signed-off-by: Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl>
> > ---
>=20
> > diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2=
x_cmn.c
> > index 4f9164c..a6da01a 100644
> > --- a/drivers/net/bnx2x/bnx2x_cmn.c
> > +++ b/drivers/net/bnx2x/bnx2x_cmn.c
> > @@ -673,6 +673,9 @@ int bnx2x_rx_int(struct bnx2x_fastpath *fp, int=
 budget)
> >  				goto reuse_rx;
> >  			}
> > =20
> > +#warning drops packets from rx queue head on memory pressure
> > +#warning (like dev_skb_finish_rx_dma_refill() users)
> > +
>=20
> We have the dropless_fc module parameter that can be configured if th=
e
> user prefers pausing on host memory pressure - the problem with that
> feature is that it is enough that one of the ring runs out of memory =
and
> the entire port is stopped. When running with 16 rings, this can lead=
 to
> serious throughput degradation - this is why it is kept as a user
> configurable option.

=46rom the code it look like dropless_fc just enables sending of pause
frames.  If that's disabled, then what happens when one queue runs out
of free rx buffers?

Best Regards,
Micha=B3 Miros=B3aw
