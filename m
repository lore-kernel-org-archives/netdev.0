From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [patch net-next 0/9] mlxsw: Support firmware flash
Date: Tue, 23 May 2017 13:18:18 +0000
Message-ID: <BLUPR0701MB2004690F775AD57D3CACB1CC8DF90@BLUPR0701MB2004.namprd07.prod.outlook.com>
References: <20170523065301.1091-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "idosch@mellanox.com" <idosch@mellanox.com>,
        "yotamg@mellanox.com" <yotamg@mellanox.com>,
        "mlxsw@mellanox.com" <mlxsw@mellanox.com>,
        Ben Hutchings <bhutchings@solarflare.com>
To: Jiri Pirko <jiri@resnulli.us>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0076.outbound.protection.outlook.com ([104.47.33.76]:28468
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S933646AbdEWNSV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 May 2017 09:18:21 -0400
In-Reply-To: <20170523065301.1091-1-jiri@resnulli.us>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Add support for device firmware flash on mlxsw spectrum. The firmware fil=
es
> are expected to be in the Mellanox Firmware Archive version 2 (MFA2)
> format.
>=20
> The firmware flash can be triggered via "ethtool -f" or on driver initial=
ization
> time if the device firmware version does not meet the minimum firmware
> version supported by the driver.
>=20
> Currently, to activate the newly flashed firmware, the user needs to rebo=
ot
> his system.
>=20
> The first patch introduces the mlxfw module, which implements common
> logic needed for the firmware flash process on Mellanox products, such as
> the
> MFA2 format parsing and the firmware flash state machine logic. As the
> module implements common logic which will be needed by various different
> Mellanox drivers, it defines a set of callbacks needed to interact with t=
he
> specific device.
>=20
> Patches 1-5 implement the needed mlxfw callbacks in the mlxsw spectrum
> driver.
>=20
> Patches 6-8 add the "ethtool -f" and the boot-time firmware upgrade on th=
e
> mlxsw spectrum driver.

When we tried using `ethtool -E' for qed we got burned for trying to use th=
e magic
value [1]. When we suggested extending it to allow some private data indica=
tions,
Ben claimed that this entire ethtool infrastructure is a thing of the past,
and we should try using MTD instead - a claim no one bothered to counter.

Creating proprietary file-formats, filling them with metadata and
complementary driver state-machines could easily overcome the original
obstacle we faced. But it raises the question of whether these APIs are
valid or obsolete.

[1] http://marc.info/?l=3Dlinux-netdev&m=3D146093513926921&w=3D4
[2] http://marc.info/?l=3Dlinux-netdev&m=3D146514461214421&w=3D2

> Patch 9 adds a fix needed for new firmware versions.
>=20
> Ido Schimmel (1):
>   mlxsw: spectrum_router: Adjust RIF configuration for new firmware
>     versions
>=20
> Yotam Gigi (8):
>   Add the mlxfw module for Mellanox firmware flash process
>   mlxsw: reg: Add Management Component Query Information register
>   mlxsw: reg: Add Management Component Control register
>   mlxsw: reg: Add Management Component Data Access register
>   mlxsw: spectrum: Add the needed callbacks for mlxfw integration
>   mlxsw: spectrum: Implement the ethtool flash_device callback
>   mlxsw: core: Create the mlxsw_fw_rev struct
>   mlxsw: spectrum: Validate firmware revision on init
>=20
>  MAINTAINERS                                        |   8 +
>  drivers/net/ethernet/mellanox/Kconfig              |   1 +
>  drivers/net/ethernet/mellanox/Makefile             |   1 +
>  drivers/net/ethernet/mellanox/mlxfw/Kconfig        |   6 +
>  drivers/net/ethernet/mellanox/mlxfw/Makefile       |   2 +
>  drivers/net/ethernet/mellanox/mlxfw/mlxfw.h        | 102 ++++
>  drivers/net/ethernet/mellanox/mlxfw/mlxfw_fsm.c    | 273 +++++++++
>  drivers/net/ethernet/mellanox/mlxfw/mlxfw_mfa2.c   | 620
> +++++++++++++++++++++
>  drivers/net/ethernet/mellanox/mlxfw/mlxfw_mfa2.h   |  66 +++
>  .../net/ethernet/mellanox/mlxfw/mlxfw_mfa2_file.h  |  60 ++
>  .../ethernet/mellanox/mlxfw/mlxfw_mfa2_format.h    | 103 ++++
>  .../net/ethernet/mellanox/mlxfw/mlxfw_mfa2_tlv.h   |  98 ++++
>  .../ethernet/mellanox/mlxfw/mlxfw_mfa2_tlv_multi.c | 126 +++++
> .../ethernet/mellanox/mlxfw/mlxfw_mfa2_tlv_multi.h |  71 +++
>  drivers/net/ethernet/mellanox/mlxsw/Kconfig        |   1 +
>  drivers/net/ethernet/mellanox/mlxsw/core.h         |  12 +-
>  drivers/net/ethernet/mellanox/mlxsw/reg.h          | 219 ++++++++
>  drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 266 +++++++++
>  .../net/ethernet/mellanox/mlxsw/spectrum_router.c  |  22 +
>  19 files changed, 2052 insertions(+), 5 deletions(-)  create mode 100644
> drivers/net/ethernet/mellanox/mlxfw/Kconfig
>  create mode 100644 drivers/net/ethernet/mellanox/mlxfw/Makefile
>  create mode 100644 drivers/net/ethernet/mellanox/mlxfw/mlxfw.h
>  create mode 100644 drivers/net/ethernet/mellanox/mlxfw/mlxfw_fsm.c
>  create mode 100644 drivers/net/ethernet/mellanox/mlxfw/mlxfw_mfa2.c
>  create mode 100644 drivers/net/ethernet/mellanox/mlxfw/mlxfw_mfa2.h
>  create mode 100644
> drivers/net/ethernet/mellanox/mlxfw/mlxfw_mfa2_file.h
>  create mode 100644
> drivers/net/ethernet/mellanox/mlxfw/mlxfw_mfa2_format.h
>  create mode 100644
> drivers/net/ethernet/mellanox/mlxfw/mlxfw_mfa2_tlv.h
>  create mode 100644
> drivers/net/ethernet/mellanox/mlxfw/mlxfw_mfa2_tlv_multi.c
>  create mode 100644
> drivers/net/ethernet/mellanox/mlxfw/mlxfw_mfa2_tlv_multi.h
>=20
> --
> 2.9.3
