From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next-2.6 1/1] e1000e: Expose MDI-X status via ethtool
	change
Date: Tue, 2 Jun 2009 16:02:23 -0700
Message-ID: <9929d2390906021602o34ad0814u129c97e9b84886d2@mail.gmail.com>
References: <1243353768.3188.2.camel@achroite>
	 <20090527231542.GA19664@clala-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Chaitanya Lala <clala@riverbed.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.248]:10779 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754318AbZFBXCX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2009 19:02:23 -0400
Received: by an-out-0708.google.com with SMTP id d40so17479474and.1
        for <netdev@vger.kernel.org>; Tue, 02 Jun 2009 16:02:24 -0700 (PDT)
In-Reply-To: <20090527231542.GA19664@clala-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 27, 2009 at 4:15 PM, Chaitanya Lala <clala@riverbed.com> wr=
ote:
> Ethtool is a standard way of getting information about ethernet
> interfaces. We enhance ethtool kernel interface & e1000e to make
> the MDI-X status readable via ethtool in userspace.
>
> Signed-off-by: Chaitanya Lala <clala@riverbed.com>
> Signed-off-by: Arthur Jones <ajones@riverbed.com>
> ---
> =C2=A0drivers/net/e1000e/ethtool.c | =C2=A0 =C2=A08 ++++++++
> =C2=A0include/linux/ethtool.h =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A08 ++=
+++++-
> =C2=A02 files changed, 15 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtoo=
l.c
> index 4d25ede..b6aea6b 100644
> --- a/drivers/net/e1000e/ethtool.c
> +++ b/drivers/net/e1000e/ethtool.c
> @@ -167,6 +167,14 @@ static int e1000_get_settings(struct net_device =
*netdev,
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0ecmd->autoneg =3D ((hw->phy.media_type =3D=
=3D e1000_media_type_fiber) ||
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 hw->mac.autoneg) ? AUTONEG_ENABLE : AUTONEG_DISABLE;
> +
> + =C2=A0 =C2=A0 =C2=A0 /* MDI-X =3D> 2; MDI =3D>1; Invalid =3D>0 */
> + =C2=A0 =C2=A0 =C2=A0 if ((hw->phy.media_type =3D=3D e1000_media_typ=
e_copper) &&
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 !hw->mac.get_link_=
status)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ecmd->is_mdix =3D =
hw->phy.is_mdix ? MDI_X : MDI;
> + =C2=A0 =C2=A0 =C2=A0 else
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ecmd->is_mdix =3D =
MDI_INVALID;
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;
> =C2=A0}
>
> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> index 380b042..b553bdb 100644
> --- a/include/linux/ethtool.h
> +++ b/include/linux/ethtool.h
> @@ -30,7 +30,8 @@ struct ethtool_cmd {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0__u32 =C2=A0 maxtxpkt; =C2=A0 =C2=A0 =C2=A0=
 /* Tx pkts before generating tx int */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0__u32 =C2=A0 maxrxpkt; =C2=A0 =C2=A0 =C2=A0=
 /* Rx pkts before generating rx int */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0__u16 =C2=A0 speed_hi;
> - =C2=A0 =C2=A0 =C2=A0 __u16 =C2=A0 reserved2;
> + =C2=A0 =C2=A0 =C2=A0 __u8 =C2=A0 =C2=A0is_mdix;
> + =C2=A0 =C2=A0 =C2=A0 __u8 =C2=A0 =C2=A0reserved2;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0__u32 =C2=A0 lp_advertising; /* Features t=
he link partner advertises */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0__u32 =C2=A0 reserved[2];
> =C2=A0};
> @@ -632,6 +633,11 @@ struct ethtool_ops {
> =C2=A0#define AUTONEG_DISABLE =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A00x00
> =C2=A0#define AUTONEG_ENABLE =C2=A0 =C2=A0 =C2=A0 =C2=A0 0x01
>
> +/* Mode MDI or MDI-X */
> +#define MDI_INVALID 0x00
> +#define MDI =C2=A0 =C2=A0 =C2=A0 =C2=A0 0x01
> +#define MDI_X =C2=A0 =C2=A0 =C2=A0 0x02
> +
> =C2=A0/* Wake-On-Lan options. */
> =C2=A0#define WAKE_PHY =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 (1 << 0)
> =C2=A0#define WAKE_UCAST =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (1=
 << 1)
> --
> 1.6.0.4
>

I have pulled this into my queue for testing and submission, thanks.

--=20
Cheers,
Jeff
