From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [RFC PATCH] vlan: convert VLAN devices to use hw_features
Date: Sat, 2 Apr 2011 14:28:57 +0200
Message-ID: <20110402122857.GA3147@rere.qmqm.pl>
References: <20110331110135.19BE6138DD@rere.qmqm.pl> <AANLkTim68LoiyFA4+3weHkmuVpc=xxmHnheiEf_OH0LK@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:44236 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756008Ab1DBM3A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Apr 2011 08:29:00 -0400
Content-Disposition: inline
In-Reply-To: <AANLkTim68LoiyFA4+3weHkmuVpc=xxmHnheiEf_OH0LK@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 01, 2011 at 06:55:04PM -0700, Jesse Gross wrote:
> 2011/3/31 Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl>:
> > diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
> > index e34ea9e..b84a46b 100644
> > --- a/net/8021q/vlan_dev.c
> > +++ b/net/8021q/vlan_dev.c
> > @@ -704,8 +704,8 @@ static int vlan_dev_init(struct net_device *dev=
)
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0(1<<__LINK_STATE_DORMANT))) |
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(1<<__LINK_STATE_PRESENT=
);
> >
> > - =A0 =A0 =A0 dev->features |=3D real_dev->features & real_dev->vla=
n_features;
> > - =A0 =A0 =A0 dev->features |=3D NETIF_F_LLTX;
> > + =A0 =A0 =A0 dev->hw_features =3D real_dev->vlan_features & NETIF_=
=46_ALL_TX_OFFLOADS;
> > + =A0 =A0 =A0 dev->features |=3D real_dev->vlan_features | NETIF_F_=
LLTX;
> Shouldn't this continue to use real_dev->feaures &
> real_dev->vlan_features?  In some places capabilities are blindly
> added to vlan_features on the assumption that they will later be ANDe=
d
> with the real capabilities of the hardware (for example, see
> register_netdevice()).

real_dev->features are ANDed on every netdev_update_features() (also ca=
lled
by register_netdevice()) by vlan_dev_fix_features(). This sets all
vlan_features as wanted to be enabled, so that if some are initially di=
sabled
on the base device and later enabled then they can be propagated back t=
o vlan
devices. The other way would be to set wanted_features based on current
real_dev->features & real_dev->vlan_features.

Hmm. I just noticed that I missed vlan_transfer_features() in the conve=
rsion.
I'll fix that.

Best Regards,
Micha=B3 Miros=B3aw
