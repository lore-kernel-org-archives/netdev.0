From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: Re: [PATCH net-next 6/9] net: hns: normalize two different loop
Date: Mon, 27 Jun 2016 15:00:35 +0300
Message-ID: <1467028835.30123.287.camel@linux.intel.com>
References: <1467021255-95900-1-git-send-email-Yisen.Zhuang@huawei.com>
	 <1467021255-95900-7-git-send-email-Yisen.Zhuang@huawei.com>
	 <1467028161.1847.101.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: liguozhu@huawei.com, huangdaode@hisilicon.com, arnd@arndb.de,
	andrew@lunn.ch, geliangtang@163.com, ivecera@redhat.com,
	fengguang.wu@intel.com, charles.chenxin@huawei.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linuxarm@huawei.com
To: Joe Perches <joe@perches.com>,
	Yisen Zhuang <Yisen.Zhuang@huawei.com>, davem@davemloft.net,
	salil.mehta@huawei.com, yankejian@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:21690 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750869AbcF0MAr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jun 2016 08:00:47 -0400
In-Reply-To: <1467028161.1847.101.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-06-27 at 04:49 -0700, Joe Perches wrote:
> On Mon, 2016-06-27 at 17:54 +0800, Yisen Zhuang wrote:
> > From: Daode Huang <huangdaode@hisilicon.com>
> >=20
> > There are two approaches to assign data, one does 2 loops, another
> > does 1 loop. This patch normalize the different methods to 1 loop.
> []
> > diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
> > b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
> []
> > @@ -2567,15 +2567,15 @@ static char
> > *hns_dsaf_get_node_stats_strings(char *data, int node,
> > =C2=A0	buff +=3D ETH_GSTRING_LEN;
> > =C2=A0	if (node < DSAF_SERVICE_NW_NUM && !is_ver1) {
> > =C2=A0		for (i =3D 0; i < DSAF_PRIO_NR; i++) {
> > -			snprintf(buff, ETH_GSTRING_LEN,
> > -				=C2=A0"inod%d_pfc_prio%d_pkts", node,
> > i);
> > -			buff +=3D ETH_GSTRING_LEN;
> > -		}
> > -		for (i =3D 0; i < DSAF_PRIO_NR; i++) {
> > -			snprintf(buff, ETH_GSTRING_LEN,
> > -				=C2=A0"onod%d_pfc_prio%d_pkts", node,
> > i);
> > +			snprintf(buff + 0 * ETH_GSTRING_LEN *
> > DSAF_PRIO_NR,
> > +				=C2=A0ETH_GSTRING_LEN,
> > "inod%d_pfc_prio%d_pkts",
> > +				=C2=A0node, i);
> > +			snprintf(buff + 1 * ETH_GSTRING_LEN *
> > DSAF_PRIO_NR,
> > +				=C2=A0ETH_GSTRING_LEN,
> > "onod%d_pfc_prio%d_pkts",
> > +				=C2=A0node, i);
> > =C2=A0			buff +=3D ETH_GSTRING_LEN;
>=20
> This looks odd and likely incorrect.

Why? the idea is to print stats for Rx and Tx at once.

I hope it was tested.

>=20
> > =C2=A0		}
> > +		buff +=3D 1 * DSAF_PRIO_NR * ETH_GSTRING_LEN;
> > =C2=A0	}
>=20

--=20

Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Intel Finland Oy
