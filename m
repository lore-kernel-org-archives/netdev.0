From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next PATCH] ixgbe: fix multiple unicast address support
Date: Tue, 10 Mar 2009 20:35:28 -0700
Message-ID: <9929d2390903102035t7d551aband3b8e793033f9c95@mail.gmail.com>
References: <20090311020024.22904.48769.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Chris Leech <christopher.leech@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.247]:62721 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752643AbZCKDfd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2009 23:35:33 -0400
Received: by an-out-0708.google.com with SMTP id c2so1366646anc.1
        for <netdev@vger.kernel.org>; Tue, 10 Mar 2009 20:35:29 -0700 (PDT)
In-Reply-To: <20090311020024.22904.48769.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 10, 2009 at 7:00 PM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> From: Chris Leech <christopher.leech@intel.com>
>
> Multiple unicast address support appears to have been broken with the
> change to support net_device_ops. =C2=A0This a regression from 2.6.28=
 to 2.6.29.
>
> I'm not 100% on whether ndo_set_multicast_list can be NULL after this
> or not. =C2=A0If ndo_set_rx_mode is set everything _should_ be using =
it.
>
> Signed-off-by: Chris Leech <christopher.leech@intel.com>
> Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>
> =C2=A0drivers/net/ixgbe/ixgbe_main.c | =C2=A0 =C2=A01 +
> =C2=A01 files changed, 1 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe=
_main.c
> index d0b9870..8e7a51b 100644
> --- a/drivers/net/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ixgbe/ixgbe_main.c
> @@ -4341,6 +4341,7 @@ static const struct net_device_ops ixgbe_netdev=
_ops =3D {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0.ndo_stop =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =3D ixgbe_close,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0.ndo_start_xmit =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =3D ixgbe_xmit_frame,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0.ndo_get_stats =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0=3D ixgbe_get_stats,
> + =C2=A0 =C2=A0 =C2=A0 .ndo_set_rx_mode =C2=A0 =C2=A0 =C2=A0 =C2=A0=3D=
 ixgbe_set_rx_mode,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0.ndo_set_multicast_list =3D ixgbe_set_rx_m=
ode,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0.ndo_validate_addr =C2=A0 =C2=A0 =C2=A0=3D=
 eth_validate_addr,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0.ndo_set_mac_address =C2=A0 =C2=A0=3D ixgb=
e_set_mac,
>
> --

Dave,
     I know that it is very late in the rc cycle, so I understand if
this change cannot make it into 2.6.29.  If it is possible, we would
like to see this 1 line change make 2.6.29.

--=20
Cheers,
Jeff
