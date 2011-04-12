From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: Re: [PATCH v4] net: bnx2x: convert to hw_features
Date: Tue, 12 Apr 2011 17:36:52 +0300
Message-ID: <1302619012.6750.8.camel@lb-tlvb-vladz>
References: <20110411202630.C079D13909@rere.qmqm.pl>
 <1302610228.32697.298.camel@lb-tlvb-vladz>
 <20110412140708.GA21835@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2237 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752033Ab1DLOhF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 10:37:05 -0400
In-Reply-To: <20110412140708.GA21835@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-04-12 at 07:07 -0700, Micha=B3 Miros=B3aw wrote:
> On Tue, Apr 12, 2011 at 03:10:28PM +0300, Vladislav Zolotarov wrote:
> > On Mon, 2011-04-11 at 13:26 -0700, Micha=B3 Miros=B3aw wrote:
> > > Since ndo_fix_features callback is postponing features change whe=
n
> > > bp->recovery_state !=3D BNX2X_RECOVERY_DONE, netdev_update_featur=
es()
> > > has to be called again when this condition changes. Previously,
> > > ethtool_ops->set_flags callback returned -EBUSY in that case
> > > (it's not possible in the new model).
> > ACK (with reservations). ;)
> > Could u, pls., just add this comment I've asked for in the previous
> > e-mail?=20
>=20
> The one about vlan_features?=20

Yeah, this one.

> I'll just fix the comment in netdevice.h
> instead, since it might be not clear enough.

Could u still add this comment to bnx2x in your patch as well. It'll
just make these code section more clear regardless the netdevice.h
contents... ;)



>=20
> > The things I first thought to comment on are:
> > 	- Removing TPA_ENABLED_FLAG the similar way u've removed the
> > bp->rx_csum.
> > 	- Merging the code handling 'features' in bnx2x_init_bp() with the
> > similar code in bnx2x_init_dev().
> >=20
> > However I think it would be right if we clear our mess by ourselves=
 and
> > that u have already done much enough... ;)=20
> >=20
> > I've run our standard test suite (which in particular heavily tests=
 the
> > RX_CSUM and LRO flags toggling) on this patch and it passed it.
>=20
> It might be possible to get rid of ndo_set_features, since it looks l=
ike
> the reset/recovery handler is doing unload/load itself. This needs mo=
re
> digging into the driver than this simple conversion.

Hmm... I don't get u here. Although the recovery handler does
unload/load itself if there has been an attempt to change features
during the recovery it won't be able to get applied until the whole
recovery process ends. So, this patch added the extra call for
netdev_update_features() right after we know that the recovery process
has successfully ended. So, could u, pls., explain exactly what do u
mean here by saying "It might be possible to get rid of
ndo_set_features"?

thanks,
vlad

>=20
> Best Regards,
> Micha=B3 Miros=B3aw
>=20



