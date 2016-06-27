From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 6/9] net: hns: normalize two different loop
Date: Mon, 27 Jun 2016 05:08:58 -0700
Message-ID: <1467029338.1847.106.camel@perches.com>
References: <1467021255-95900-1-git-send-email-Yisen.Zhuang@huawei.com>
	 <1467021255-95900-7-git-send-email-Yisen.Zhuang@huawei.com>
	 <1467028161.1847.101.camel@perches.com>
	 <1467028835.30123.287.camel@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: liguozhu@huawei.com, huangdaode@hisilicon.com, arnd@arndb.de,
	andrew@lunn.ch, geliangtang@163.com, ivecera@redhat.com,
	fengguang.wu@intel.com, charles.chenxin@huawei.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linuxarm@huawei.com
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	Yisen Zhuang <Yisen.Zhuang@huawei.com>, davem@davemloft.net,
	salil.mehta@huawei.com, yankejian@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467028835.30123.287.camel@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-06-27 at 15:00 +0300, Andy Shevchenko wrote:
> On Mon, 2016-06-27 at 04:49 -0700, Joe Perches wrote:
> >=20
> > On Mon, 2016-06-27 at 17:54 +0800, Yisen Zhuang wrote:
> > >=20
> > > From: Daode Huang <huangdaode@hisilicon.com>
> > >=20
> > > There are two approaches to assign data, one does 2 loops, anothe=
r
> > > does 1 loop. This patch normalize the different methods to 1 loop=
=2E
> > []
> > >=20
> > > diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
> > > b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
> > []
> > >=20
> > > @@ -2567,15 +2567,15 @@ static char
> > > *hns_dsaf_get_node_stats_strings(char *data, int node,
> > > =A0	buff +=3D ETH_GSTRING_LEN;
> > > =A0	if (node < DSAF_SERVICE_NW_NUM && !is_ver1) {
> > > =A0		for (i =3D 0; i < DSAF_PRIO_NR; i++) {
> > > -			snprintf(buff, ETH_GSTRING_LEN,
> > > -				=A0"inod%d_pfc_prio%d_pkts", node,
> > > i);
> > > -			buff +=3D ETH_GSTRING_LEN;
> > > -		}
> > > -		for (i =3D 0; i < DSAF_PRIO_NR; i++) {
> > > -			snprintf(buff, ETH_GSTRING_LEN,
> > > -				=A0"onod%d_pfc_prio%d_pkts", node,
> > > i);
> > > +			snprintf(buff + 0 * ETH_GSTRING_LEN *
> > > DSAF_PRIO_NR,
> > > +				=A0ETH_GSTRING_LEN,
> > > "inod%d_pfc_prio%d_pkts",
> > > +				=A0node, i);
> > > +			snprintf(buff + 1 * ETH_GSTRING_LEN *
> > > DSAF_PRIO_NR,
> > > +				=A0ETH_GSTRING_LEN,
> > > "onod%d_pfc_prio%d_pkts",
> > > +				=A0node, i);
> > > =A0			buff +=3D ETH_GSTRING_LEN;
> > This looks odd and likely incorrect.
> Why? the idea is to print stats for Rx and Tx at once.
>=20
> I hope it was tested.

It changes the order of the strings in buff.
Is a bug fix or a style fix?

If it's a bug fix, then it should likely be added
to the stable trees.
