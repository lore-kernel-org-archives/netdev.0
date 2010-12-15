From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH 3/3] net: Fix drivers advertising HW_CSUM feature to
	use csum_start
Date: Wed, 15 Dec 2010 19:58:41 +0100
Message-ID: <20101215185841.GA7116@rere.qmqm.pl>
References: <cover.1292372504.git.mirq-linux@rere.qmqm.pl> <aa9d85fa4961e87c38aec922913cbc95465fc082.1292372504.git.mirq-linux@rere.qmqm.pl> <20101214190727.0ed1a925@nehalam> <20101215181655.GA29962@rere.qmqm.pl> <20101215102536.6430274b@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	Vasanthy Kolluri <vkolluri@cisco.com>,
	Roopa Prabhu <roprabhu@cisco.com>,
	David Wang <dwang2@cisco.com>,
	Andrew Gallatin <gallatin@myri.com>,
	Brice Goglin <brice@myri.com>,
	Shreyas Bhatewara <sbhatewara@vmware.com>,
	"VMware, Inc." <pv-drivers@vmware.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jiri Pirko <jpirko@redhat.com>,
	H Hartley Sweeten <hsweeten@visionengravers.com>,
	Jie Yang <Jie.Yang@atheros.com>, Joe Perches <joe@perches.com>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:56496 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753511Ab0LOS6n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Dec 2010 13:58:43 -0500
Content-Disposition: inline
In-Reply-To: <20101215102536.6430274b@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 15, 2010 at 10:25:36AM -0800, Stephen Hemminger wrote:
> On Wed, 15 Dec 2010 19:16:55 +0100
> Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl> wrote:
> > On Tue, Dec 14, 2010 at 07:07:27PM -0800, Stephen Hemminger wrote:
> > > On Wed, 15 Dec 2010 02:24:08 +0100 (CET)
> > > Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl> wrote:
> > > > Some drivers are using skb_transport_offset(skb) instead of skb=
->csum_start
> > > > for NETIF_F_HW_CSUM offload.  This does not matter now, but if =
someone
> > > > implements checksumming of encapsulated packets then this will =
break silently.
[...]
> > > Which if any of these drivers did you test on real hardware?
> > I'm running it on skge, with additional patch that changes it to us=
e
> > NETIF_F_HW_CSUM instead of NETIF_F_IP_CSUM. BTW, why it is not adve=
rtising
> > full HW checksum in vanilla kernel? Are there any known hardware bu=
gs in there?
> The driver was written from vendor sk98lin driver and that driver
> only did IP checksum, therefore I did not trust the hardware.
> The chipset is old, and not used in new designs, no documentation
> is up to date (and I didn't have any).
>=20
> Please don't enable non-IPv4 checksum offload on this hardware, there
> is too big a risk of it not working on all hardware.

Sure, this can stay in my private patchlist. I can also add a module op=
tion
(disabled by default) for the brave ones if you'd accept that.

Best Regards,
Micha=B3 Miros=B3aw
