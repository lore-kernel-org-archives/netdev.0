From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH] net offloading: Do not mask out NETIF_F_HW_VLAN_TX
 for vlan.
Date: Tue, 18 Jan 2011 09:21:52 -0800
Message-ID: <1295371312.10343.13.camel@nseg_linux_HP1.broadcom.com>
References: <1295333160-1667-1-git-send-email-jesse@nicira.com>
 <1295333714.3362.561.camel@edumazet-laptop>
 <AANLkTikmadouBTgkf4OZy30=Zg6uZ+qSng=rWhTjjm8e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Eric Dumazet" <eric.dumazet@gmail.com>,
	"David Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Jesse Gross" <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4506 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752686Ab1ARR0P convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jan 2011 12:26:15 -0500
In-Reply-To: <AANLkTikmadouBTgkf4OZy30=Zg6uZ+qSng=rWhTjjm8e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 2011-01-17 at 23:12 -0800, Jesse Gross wrote:
> On Tue, Jan 18, 2011 at 1:55 AM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
> > Le lundi 17 janvier 2011 =C3=A0 22:46 -0800, Jesse Gross a =C3=A9cr=
it :
> >> In netif_skb_features() we return only the features that are valid=
 for vlans
> >> if we have a vlan packet.  However, we should not mask out NETIF_F=
_HW_VLAN_TX
> >> since it enables transmission of vlan tags and is obviously valid.
> >>
> >> Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
> >> Signed-off-by: Jesse Gross <jesse@nicira.com>
> >
> > Thanks Jesse
> >
> > Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
> >
> > Now back to the "ethtool -K eth0 txvlan off" problem on bnx2
> >
> > Is it a driver/software problem or hardware/firmware one ?
>=20
> CC'ing Michael Chan
>=20
> It looks like bnx2 is storing the offsets of various headers so the
> hardware can find them for TSO.  The parsing logic doesn't do anythin=
g
> for vlan tags, so the hardware gets confused if one is present in the
> packet itself.

Yeah, I don't think the hardware/firmware can replicate the vlan tag +
headers properly for TSO if there is a VLAN tag in the packet.  Even
simple tx checksum offload may have problem, but I'll need to check.

>=20
> Quick fix is to simply disallow disabling TX vlan offload or disable
> TSO at the same time or some other Ethtool game.  However, if the
> hardware supports it then it would be nicer to fix up the TSO setup
> logic.  Maybe we can just add the size of the vlan tag to the offset
> but I am not certain.  Michael, do you know if this is possible?
>=20

I doubt it, as the VLAN tag needs to be replicated for each transmitted
packet.  I'll check with the firmware/hardware guys.

Thanks.


