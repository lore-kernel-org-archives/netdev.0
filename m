From: Yisen Zhuang <Yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next 00/10] net: hns: add support of debug dsaf device
Date: Thu, 28 Apr 2016 14:47:52 +0800
Message-ID: <5721B218.7060000@huawei.com>
References: <1461826902-51368-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <mark.rutland-5wv7dgnIgG8@public.gmane.org>, <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
	<ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>, <catalin.marinas-5wv7dgnIgG8@public.gmane.org>,
	<will.deacon-5wv7dgnIgG8@public.gmane.org>, <linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	<galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1461826902-51368-1-git-send-email-Yisen.Zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

I am sorry for my misoperation, please ignore this series, thanks.

=E5=9C=A8 2016/4/28 15:01, Yisen Zhuang =E5=86=99=E9=81=93:
> There are two kinds of dsaf device in hns, one is for service ports,
> contains crossbar in it, can work under different mode. Another is fo=
r
> debug port, only can work under single port mode. The current code on=
ly
> declared a dsaf device for both service ports and debug ports.It is n=
ot so
> readability. This patch separate it to three platform devices to make=
 the
> code simple and more readability.
>=20
> all port in one platform device(old):
>                                         CPU
>                                          |
>                                          |        DSAF(one platform d=
evice)
>     --------------------------------------------------------------   =
   /
>     |                           |                  |      |      |   =
  /
>     |                          PPE                PPE    PPE     |   =
 /
>     |                           |                  |      |      |   =
/
>     |                           |                  |      |      |  /
>     |                        crossbar              |      |      | /
>     |                           |                  |      |      |/
>     |    -----------------------------------       |      |      |
>     |    |      |      |      |      |      |      |      |      |
>     |    |      |      |      |      |      |      |      |      |
>     |   MAC    MAC    MAC    MAC    MAC    MAC    MAC    MAC     |
>     |    |      |      |      |      |      |      |      |      |
>     --------------------------------------------------------------
>          |      |      |      |      |      |      |      |
>         PHY    PHY    PHY    PHY    PHY    PHY    PHY    PHY
>=20
> separate all ports to three platform(new):
>                                                          CPU
>                                                           |
>                                     ---------------------------------=
--
>                                     |                     |          =
 |
>     ----------------------------------------------    ---------   ---=
------
>     |                         |                  |    |       |   |  =
 |   |
>     |                        PPE                 |    |  PPE  |   |  =
PPE  |
>     |                         |                  |    |   |   |   |  =
 |   |
>     |                         |                  |    |   |   |   |  =
 |   |
>     |                      crossbar              |    |   |   |   |  =
 |   |
>     |                         |                  |    |   |   |   |  =
 |   |
>     |   ----------------------------------       |    |   |   |   |  =
 |   |
>     |   |     |     |      |      |      |       |    |   |   |   |  =
 |   |
>     |   |     |     |      |      |      |       |    |   |   |   |  =
 |   |
>     |  MAC   MAC   MAC    MAC    MAC    MAC      |    |  MAC  |   |  =
MAC  |
>     |   |     |     |      |      |      |       |    |   |   |   |  =
 |   |
>     ----------------------------------------------    ---------   ---=
------
>         |     |     |      |      |      |    \        /  |        / =
 |
>        PHY   PHY   PHY    PHY    PHY    PHY    \      /  PHY      /  =
PHY
>                                                 \    /           /
>                                                  \  /           /
>                                              DSAF(three platform devi=
ce)
>=20
> I have tested this patchset on d02 board, it is compatible with the d=
ts in
> d02 board.
>=20
> For more details, please see individual patches.
>=20
> MBR.
>=20
> Daode Huang (3):
>   net: hns: set debug port irq index to 0
>   net: hns: add syscon operation for dsaf
>   net: hns: sort the header file by alphabetical order
>=20
> Yisen Zhuang (6):
>   net: hns: add attribute port-idx-in-ae in enet node.
>   net: hns: add attribute reset-field-offset for dsaf node
>   net: hns: separate debug dsaf device from service dsaf device
>   net: hns: add attribute cpld_ctrl for dsaf port node
>   net: hns: add attribute port-rst-offset for dsaf port node
>   net: hns: add attribute port-mode-offset for dsaf port node
>=20
> huangdaode (1):
>   net: hns: add a new dsaf mode for debug port
>=20
>  .../devicetree/bindings/net/hisilicon-hns-dsaf.txt |  60 +++++-
>  .../devicetree/bindings/net/hisilicon-hns-nic.txt  |  30 ++-
>  drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c  |  73 ++-----
>  drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c  | 231 +++++++++++=
+++-------
>  drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h  |  12 +-
>  drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c | 141 ++++++++---=
--
>  drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h |  16 +-
>  drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c | 173 +++++++++--=
----
>  drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c  |  51 +----
>  drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.h  |   1 -
>  drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c  | 187 +++++++----=
------
>  drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.h  |   2 +-
>  drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h  |  38 ++--
>  drivers/net/ethernet/hisilicon/hns/hns_enet.c      |  17 +-
>  drivers/net/ethernet/hisilicon/hns/hns_enet.h      |   3 +
>  15 files changed, 584 insertions(+), 451 deletions(-)
>=20

--
To unsubscribe from this list: send the line "unsubscribe devicetree" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
