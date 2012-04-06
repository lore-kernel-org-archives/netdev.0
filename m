From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH V4 net-next 05/26] bfin_mac: Support the get_ts_info
 ethtool method.
Date: Fri, 6 Apr 2012 00:08:52 -0400
Message-ID: <CAP=VYLq1kCqLxi31HcGavKk8e3ydX43Xz-7rwayLJPWAnfk28Q@mail.gmail.com>
References: <cover.1333529504.git.richardcochran@gmail.com> <88e5b2cfcabda03826bb576b21e2e1d990f07117.1333529506.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Martin Porter <mporter@solarflare.com>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	e1000-devel@lists.sourceforge.net, linux-next@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <88e5b2cfcabda03826bb576b21e2e1d990f07117.1333529506.git.richardcochran@gmail.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 4, 2012 at 4:59 AM, Richard Cochran
<richardcochran@gmail.com> wrote:
> Signed-off-by: Richard Cochran <richardcochran@gmail.com>
> ---
> =A0drivers/net/ethernet/adi/bfin_mac.c | =A0 20 ++++++++++++++++++++
> =A01 files changed, 20 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethern=
et/adi/bfin_mac.c
> index ab4daec..db22278 100644
> --- a/drivers/net/ethernet/adi/bfin_mac.c
> +++ b/drivers/net/ethernet/adi/bfin_mac.c
> @@ -548,6 +548,25 @@ static int bfin_mac_ethtool_setwol(struct net_de=
vice *dev,
> =A0 =A0 =A0 =A0return 0;
> =A0}
>
> +static int bfin_mac_ethtool_get_ts_info(struct net_device *dev,
> + =A0 =A0 =A0 struct ethtool_ts_info *info);

   ----------------------------------->  ^^^^^^^

Trailing semicolon.  Compile fail in linux-next due to a85bbddd.

http://kisskb.ellerman.id.au/kisskb/buildresult/6040086/
http://kisskb.ellerman.id.au/kisskb/buildresult/6040080/
http://kisskb.ellerman.id.au/kisskb/buildresult/6040087/

Thanks.
Paul.

> +{
> + =A0 =A0 =A0 info->so_timestamping =3D
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 SOF_TIMESTAMPING_TX_HARDWARE |
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 SOF_TIMESTAMPING_RX_HARDWARE |
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 SOF_TIMESTAMPING_SYS_HARDWARE;
> + =A0 =A0 =A0 info->phc_index =3D -1;
> + =A0 =A0 =A0 info->tx_types =3D
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 (1 << HWTSTAMP_TX_OFF) |
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 (1 << HWTSTAMP_TX_ON);
> + =A0 =A0 =A0 info->rx_filters =3D
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 (1 << HWTSTAMP_FILTER_NONE) |
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 (1 << HWTSTAMP_FILTER_PTP_V1_L4_EVENT) =
|
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 (1 << HWTSTAMP_FILTER_PTP_V2_L2_EVENT) =
|
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 (1 << HWTSTAMP_FILTER_PTP_V2_L4_EVENT);
> + =A0 =A0 =A0 return 0;
> +}
> +
> =A0static const struct ethtool_ops bfin_mac_ethtool_ops =3D {
> =A0 =A0 =A0 =A0.get_settings =3D bfin_mac_ethtool_getsettings,
> =A0 =A0 =A0 =A0.set_settings =3D bfin_mac_ethtool_setsettings,
> @@ -555,6 +574,7 @@ static const struct ethtool_ops bfin_mac_ethtool_=
ops =3D {
> =A0 =A0 =A0 =A0.get_drvinfo =3D bfin_mac_ethtool_getdrvinfo,
> =A0 =A0 =A0 =A0.get_wol =3D bfin_mac_ethtool_getwol,
> =A0 =A0 =A0 =A0.set_wol =3D bfin_mac_ethtool_setwol,
> + =A0 =A0 =A0 .get_ts_info =3D bfin_mac_ethtool_get_ts_info,
> =A0};
>
> =A0/*****************************************************************=
*********/
> --
> 1.7.2.5
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
