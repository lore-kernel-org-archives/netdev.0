From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] ixgbe: get pauseparam autoneg
Date: Fri, 16 Sep 2011 01:19:53 -0700
Message-ID: <CAL3LdT79dUF1bW0CxvtMBQTikh4NqapuZaOg6PT67LtJ4Oqdzg@mail.gmail.com>
References: <op.v1ozj4zk6ywr33@esapekka-pc.rad1>
	<op.v1v077z76ywr33@esapekka-pc.rad1>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"mika.lansirinne@stonesoft.com" <mika.lansirinne@stonesoft.com>
To: Esa-Pekka Pyokkimies <esa-pekka.pyokkimies@stonesoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:44163 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754363Ab1IPITy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2011 04:19:54 -0400
Received: by fxe4 with SMTP id 4so1430942fxe.19
        for <netdev@vger.kernel.org>; Fri, 16 Sep 2011 01:19:53 -0700 (PDT)
In-Reply-To: <op.v1v077z76ywr33@esapekka-pc.rad1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 15, 2011 at 23:20, Esa-Pekka Pyokkimies
<esa-pekka.pyokkimies@stonesoft.com> wrote:
> There is a problem in the ixgbe driver with the reporting of the flow
> control parameters. The autoneg parameter is shown to be of if
> *either* it really is off, or current modes for both tx and rx are of=
f.
>
> The problem is seen when the parameters are read or set when the link
> is down. In this case, the driver sees that tx and rx are currently o=
ff
> and therefore autoneg parameter is incorrectly reported to be off too=
=2E
> Also, the ethtool binary can not set the autoneg off since it sees th=
at
> it already is. When a link later comes up, the autonegotiation is
> carried out normally and the driver later on reports the autoneg
> parameter to be on (as it is) and then it can also be changed with
> ethtool.
>
> The patch is made against v3.0 kernel, but the problem seems to be th=
ere
> since v2.6.30-rc1.
>
> Reviewer comments: What we are trying to do is to disable flow contro=
l
> while the cable is disconnected. Since ixgbe defaults to full flow
> control, we call ethtool -A autoneg off rx off tx off while the cable
> is disconnected. This doesn't work, because the driver sets
> hw->fc.current_mode =3D ixgbe_fc_none if the cable is unplugged.
> ixgbe_get_pauseparam() then reports to ethtool that nothing needs to =
be
> done. The code fixes this, but it might have some unknown consequence=
s.
>
> Signed-off-by: Mika Lansirinne <mika.lansirinne@stonesoft.com>
> Reviewed-by: Esa-Pekka Pyokkimies <esa-pekka.pyokkimies@stonesoft.com=
>
> Cc: Tantilov, Emil S <emil.s.tantilov@intel.com>
> ---
> diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c
> b/drivers/net/ixgbe/ixgbe_ethtool.c
> index 82d4244..db27c24 100644
> --- a/drivers/net/ixgbe/ixgbe_ethtool.c
> +++ b/drivers/net/ixgbe/ixgbe_ethtool.c
> @@ -368,13 +368,7 @@ static void ixgbe_get_pauseparam(struct net_devi=
ce
> *netdev,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct ixgbe_adapter *adapter =3D netdev_p=
riv(netdev);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct ixgbe_hw *hw =3D &adapter->hw;
>
> - =C2=A0 =C2=A0 =C2=A0 /*
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0* Flow Control Autoneg isn't on if
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0* =C2=A0- we didn't ask for it OR
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0* =C2=A0- it failed, we know this by tx =
& rx being off
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> - =C2=A0 =C2=A0 =C2=A0 if (hw->fc.disable_fc_autoneg ||
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (hw->fc.current_mode =3D=3D ixgb=
e_fc_none))
> + =C2=A0 =C2=A0 =C2=A0 if (hw->fc.disable_fc_autoneg)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pause->autoneg=
 =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0else
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pause->autoneg=
 =3D 1;
> --

Thanks!  I have applied this patch to my queue.

--=20
Cheers,
Jeff
