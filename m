From: Timur Tabi <timur.tabi@gmail.com>
Subject: Re: [alsa-devel] [PATCH 13/27] drivers/net/of: don't use deprecated
	field in of_platform_driver
Date: Fri, 26 Mar 2010 10:23:14 -0500
Message-ID: <ed82fe3e1003260823q5a2ba774ifd3465b41b8f0a10@mail.gmail.com>
References: <20100311181604.13103.30088.stgit@angua> <20100311182259.13103.87535.stgit@angua>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: devicetree-discuss@lists.ozlabs.org, netdev@vger.kernel.org
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f223.google.com ([209.85.220.223]:63595 "EHLO
	mail-fx0-f223.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754150Ab0CZPXi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Mar 2010 11:23:38 -0400
Received: by fxm23 with SMTP id 23so2224477fxm.21
        for <netdev@vger.kernel.org>; Fri, 26 Mar 2010 08:23:36 -0700 (PDT)
In-Reply-To: <20100311182259.13103.87535.stgit@angua>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm seeing this error with this patch applied, when building for an mpc=
8641_hpcn

  CC      drivers/net/gianfar.o
drivers/net/gianfar.c: In function 'gfar_of_init':
drivers/net/gianfar.c:606: error: 'struct platform_device' has no
member named 'node'
drivers/net/gianfar.c:644: error: 'struct platform_device' has no
member named 'node'
drivers/net/gianfar.c: In function 'gfar_probe':
drivers/net/gianfar.c:891: error: 'struct platform_device' has no
member named 'node'
make[2]: *** [drivers/net/gianfar.o] Error 1
make[1]: *** [drivers/net] Error 2
make: *** [drivers] Error 2


On Thu, Mar 11, 2010 at 1:23 PM, Grant Likely <grant.likely@secretlab.c=
a> wrote:
> .name, .match_table and .owner are duplicated in both of_platform_dri=
ver
> and device_driver, so the of_platform_driver copies will be removed s=
oon.
>
> Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
> ---
>
> =A0drivers/net/can/mscan/mpc5xxx_can.c =A0 =A0 =A0 =A0 =A0 | =A0 =A08=
 +++++---
> =A0drivers/net/can/sja1000/sja1000_of_platform.c | =A0 =A08 +++++---
> =A0drivers/net/ehea/ehea_main.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =
=A0 =A07 +++++--
> =A0drivers/net/fs_enet/fs_enet-main.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A0=
7 +++++--
> =A0drivers/net/fs_enet/mii-bitbang.c =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A0=
7 +++++--
> =A0drivers/net/fs_enet/mii-fec.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0=
 =A07 +++++--
> =A0drivers/net/fsl_pq_mdio.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
| =A0 =A07 +++++--
> =A0drivers/net/gianfar.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 | =A0 10 ++++++----
> =A0drivers/net/ibm_newemac/core.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0=
 =A08 +++++---
> =A0drivers/net/ibm_newemac/mal.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0=
 =A08 +++++---
> =A0drivers/net/ibm_newemac/rgmii.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =
=A08 +++++---
> =A0drivers/net/ibm_newemac/tah.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0=
 =A08 +++++---
> =A0drivers/net/ibm_newemac/zmii.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0=
 =A08 +++++---
> =A0drivers/net/ll_temac_main.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =
=A0 =A02 +-
> =A0drivers/net/myri_sbus.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 | =A0 =A07 +++++--
> =A0drivers/net/niu.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 | =A0 =A07 +++++--
> =A0drivers/net/phy/mdio-gpio.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =
=A0 =A07 +++++--
> =A0drivers/net/sunbmac.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 | =A0 =A07 +++++--
> =A0drivers/net/sunhme.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0| =A0 =A07 +++++--
> =A0drivers/net/sunlance.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0| =A0 =A07 +++++--
> =A0drivers/net/sunqe.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 | =A0 =A07 +++++--
> =A0drivers/net/ucc_geth.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0| =A0 =A07 +++++--
> =A0drivers/net/xilinx_emaclite.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0=
 =A07 +++++--
> =A023 files changed, 112 insertions(+), 54 deletions(-)

--=20
Timur Tabi
Linux kernel developer at Freescale
