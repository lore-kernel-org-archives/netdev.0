From: Chen-Yu Tsai <wens@csie.org>
Subject: Re: [PATCH net-next 00/11] convert stmmac glue layers into platform drivers
Date: Thu, 14 May 2015 23:24:48 +0800
Message-ID: <CAGb2v663efjkwgRjPdxV4CQxeesiu7jxkMf9j_oPU_bSHbNNiA@mail.gmail.com>
References: <1431598266-25736-1-git-send-email-manabian@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Arnd Bergmann <arnd@arndb.de>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Roger <roger.chen@rock-chips.com>, Chen-Yu Tsai <wens@csie.org>,
	Srinivas KANDAGATLA <srinivas.kandagatla@st.com>,
	dinguyen@opensource.altera.com, b.galvani@gmail.com,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
	linux-rockchip@lists.infradead.org
To: Joachim Eastwood <manabian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.csie.ntu.edu.tw ([140.112.30.61]:43552 "EHLO
	smtp.csie.ntu.edu.tw" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932640AbbENPZP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 11:25:15 -0400
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	(Authenticated sender: b93043)
	by smtp.csie.ntu.edu.tw (Postfix) with ESMTPSA id 32B50202BB
	for <netdev@vger.kernel.org>; Thu, 14 May 2015 23:25:11 +0800 (CST)
Received: by igbsb11 with SMTP id sb11so75811099igb.0
        for <netdev@vger.kernel.org>; Thu, 14 May 2015 08:25:09 -0700 (PDT)
In-Reply-To: <1431598266-25736-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 14, 2015 at 6:10 PM, Joachim Eastwood <manabian@gmail.com> wrote:
> This patch set aims to convert the current dwmac glue layers into
> proper platform drivers as request by Arnd[1]. These changes start
> from patch 3 and onwards.
>
> Overview:
> Platform driver functions like probe and remove are exported from
> the stmmac platform and then used in subsequent glue later
> conversions. The conversion involes adding the platform driver
> boiler plate code and adding it to the build system. The last patch
> removes the driver from the stmmac platform code thus making it into
> a library for common platform driver functions.
>
> The two first patches adds glue layer for my platform. I chose to
> first add old style glue layer and then convert it. The churn this
> creates is just 3 lines.
>
> I would be very nice if people could test this patch set on their
> respective platform. My testing has been limited to compiling and
> testing on my (LPC18xx) platform. Thanks!

Tested-by: Chen-Yu Tsai <wens@csie.org>

on sunxi boards Cubietruck and Hummingbird A31.

> Next I will look into cleaning up the stmmac platform code.
>
> [1] http://marc.info/?l=linux-arm-kernel&m=143059524606459&w=2
>
> Joachim Eastwood (11):
>   stmmac: add dwmac glue for NXP 18xx/43xx family
>   doc: dt: add documentation for nxp,lpc1850-dwmac
>   stmmac: prepare stmmac platform to support stand alone drivers
>   stmmac: add a generic dwmac driver
>   stmmac: convert dwmac-lpc18xx to a platform driver
>   stmmac: convert dwmac-meson to platform driver
>   stmmac: convert dwmac-rk to platform driver
>   stmmac: convert dwmac-socfpga to platform driver
>   stmmac: convert dwmac-sti to platform driver
>   stmmac: convert dwmac-sunxi to platform driver
>   stmmac: drop driver from stmmac platform code
>
>  .../devicetree/bindings/net/nxp,lpc1850-dwmac.txt  | 20 +++++
>  drivers/net/ethernet/stmicro/stmmac/Kconfig        | 76 +++++++++++++++++
>  drivers/net/ethernet/stmicro/stmmac/Makefile       | 13 ++-
>  .../net/ethernet/stmicro/stmmac/dwmac-generic.c    | 41 +++++++++
>  .../net/ethernet/stmicro/stmmac/dwmac-lpc18xx.c    | 99 ++++++++++++++++++++++
>  drivers/net/ethernet/stmicro/stmmac/dwmac-meson.c  | 24 +++++-
>  drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c     | 27 +++++-
>  .../net/ethernet/stmicro/stmmac/dwmac-socfpga.c    | 21 ++++-
>  drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c    | 29 ++++++-
>  drivers/net/ethernet/stmicro/stmmac/dwmac-sunxi.c  | 25 +++++-
>  .../net/ethernet/stmicro/stmmac/stmmac_platform.c  | 49 ++---------
>  .../net/ethernet/stmicro/stmmac/stmmac_platform.h  |  9 +-
>  12 files changed, 378 insertions(+), 55 deletions(-)
>  create mode 100644 Documentation/devicetree/bindings/net/nxp,lpc1850-dwmac.txt
>  create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac-generic.c
>  create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac-lpc18xx.c
>
> --
> 1.8.0
>
