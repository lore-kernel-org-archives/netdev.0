From: Yuval Mintz <yuvalm@mellanox.com>
Subject: RE: [PATCH net-next 0/2] Add mqprio hardware offload support in hns3
 driver
Date: Thu, 12 Oct 2017 20:21:04 +0000
Message-ID: <AM0PR0502MB36837A27C3EAA2A08590D709BF4B0@AM0PR0502MB3683.eurprd05.prod.outlook.com>
References: <1507775912-22402-1-git-send-email-linyunsheng@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "huangdaode@hisilicon.com" <huangdaode@hisilicon.com>,
        "xuwei5@hisilicon.com" <xuwei5@hisilicon.com>,
        "liguozhu@hisilicon.com" <liguozhu@hisilicon.com>,
        "Yisen.Zhuang@huawei.com" <Yisen.Zhuang@huawei.com>,
        "gabriele.paoloni@huawei.com" <gabriele.paoloni@huawei.com>,
        "john.garry@huawei.com" <john.garry@huawei.com>,
        "linuxarm@huawei.com" <linuxarm@huawei.com>,
        "yisen.zhuang@huawei.com" <yisen.zhuang@huawei.com>,
        "salil.mehta@huawei.com" <salil.mehta@huawei.com>,
        "lipeng321@huawei.com" <lipeng321@huawei.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Yunsheng Lin <linyunsheng@huawei.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1507775912-22402-1-git-send-email-linyunsheng@huawei.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> This patchset adds a new hardware offload type in mqprio before adding
> mqprio hardware offload support in hns3 driver.

I think one of the biggest issues in tying this to DCB configuration is the
non-immediate [and possibly non persistent] configuration.

Scenario #1:
User is configuring mqprio offloaded with 3 TCs while device is in willing =
mode.
Would you expect the driver to immediately respond with a success or instea=
d
delay the return until the DCBx negotiation is complete and the operational
num of TCs is actually 3?

Scenario #2:
Assume user explicitly offloaded mqprio with 3 TCs, but now DCB configurati=
on
has changed on the peer side and 4 TCs is the new negotiated operational va=
lue.
Your current driver logic would change the number of TCs underneath the use=
r
configuration [and it would actually probably work due to mqprio being a cr=
appy
qdisc]. But was that the user actual intention?
[I think the likely answer in this scenario is 'yes' since the alternative =
is no better.
But I still thought it was worth mentioning]

Cheers,
Yuval

>=20
> Yunsheng Lin (2):
>   mqprio: Add a new hardware offload type in mqprio
>   net: hns3: Add mqprio hardware offload support in hns3 driver
>=20
>  drivers/net/ethernet/hisilicon/hns3/hnae3.h        |  1 +
>  .../net/ethernet/hisilicon/hns3/hns3pf/hclge_dcb.c | 23 +++++++++++
>  .../net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c | 46 ++++++++++++++-
> -------
>  include/uapi/linux/pkt_sched.h                     |  1 +
>  4 files changed, 55 insertions(+), 16 deletions(-)
>=20
> --
> 1.9.1
