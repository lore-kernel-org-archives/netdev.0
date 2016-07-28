From: Yisen Zhuang <Yisen.zhuang@huawei.com>
Subject: Re: [PATCH 06/15] ethernet: hisilicon: hns: hns_dsaf_mac: add missing
 of_node_put after calling of_parse_phandle
Date: Thu, 28 Jul 2016 08:38:08 +0800
Message-ID: <579953F0.5010906@huawei.com>
References: <1469586048-15697-1-git-send-email-peter.chen@nxp.com>
 <1469586048-15697-7-git-send-email-peter.chen@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <vbridger@opensource.altera.com>,
	<isubramanian@apm.com>, <kchudgar@apm.com>,
	<salil.mehta@huawei.com>, <thomas.petazzoni@free-electrons.com>,
	<sergei.shtylyov@cogentembedded.com>, <peppe.cavallaro@st.com>,
	<alexandre.torgue@st.com>, <mugunthanvnm@ti.com>,
	<tremyfr@gmail.com>, <wxt@rock-chips.com>, <arnd@arndb.de>,
	<david.daney@cavium.com>, <huangdaode@hisilicon.com>,
	<jszhang@marvell.com>
To: Peter Chen <peter.chen@nxp.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:34118 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758277AbcG1AjB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jul 2016 20:39:01 -0400
In-Reply-To: <1469586048-15697-7-git-send-email-peter.chen@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



=E5=9C=A8 2016/7/27 10:20, Peter Chen =E5=86=99=E9=81=93:
> of_node_put needs to be called when the device node which is got
> from of_parse_phandle has finished using.
>=20
> Signed-off-by: Peter Chen <peter.chen@nxp.com>
> ---
>  drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c | 9 ++++++---
>  1 file changed, 6 insertions(+), 3 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c b/driv=
ers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
> index 3fb87e2..18d72ea 100644
> --- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
> +++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
> @@ -786,6 +786,7 @@ static int  hns_mac_get_info(struct hns_mac_cb *m=
ac_cb)
>  		np =3D of_parse_phandle(mac_cb->dev->of_node, "phy-handle",
>  				      mac_cb->mac_id);
>  		mac_cb->phy_dev =3D of_phy_find_device(np);
> +		of_node_put(np);
>  		if (mac_cb->phy_dev) {
>  			/* refcount is held by of_phy_find_device()
>  			 * if the phy_dev is found

np is accessed in case of of_phy_find_device() returns a no null value,=
 so it has to be
moved after the dev_dbg log.

> @@ -804,6 +805,7 @@ static int  hns_mac_get_info(struct hns_mac_cb *m=
ac_cb)
>  		np =3D of_parse_phandle(to_of_node(mac_cb->fw_port),
>  				      "phy-handle", 0);
>  		mac_cb->phy_dev =3D of_phy_find_device(np);
> +		of_node_put(np);
>  		if (mac_cb->phy_dev) {
>  			/* refcount is held by of_phy_find_device()
>  			 * if the phy_dev is found

np is accessed in case of of_phy_find_device() returns a no null value,=
 so it has to be
moved after the dev_dbg log.

Thanks,

Yisen

> @@ -813,9 +815,10 @@ static int  hns_mac_get_info(struct hns_mac_cb *=
mac_cb)
>  				mac_cb->mac_id, np->name);
>  		}
> =20
> -		syscon =3D syscon_node_to_regmap(
> -				of_parse_phandle(to_of_node(mac_cb->fw_port),
> -						 "serdes-syscon", 0));
> +		np =3D of_parse_phandle(to_of_node(mac_cb->fw_port),
> +					"serdes-syscon", 0);
> +		syscon =3D syscon_node_to_regmap(np);
> +		of_node_put(np);
>  		if (IS_ERR_OR_NULL(syscon)) {
>  			dev_err(mac_cb->dev, "serdes-syscon is needed!\n");
>  			return -EINVAL;
>=20
