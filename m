From: Chen-Yu Tsai <wens@csie.org>
Subject: Re: [PATCH net-next v3] net: stmmac: add platform init/exit for
 Altera's ARM socfpga
Date: Sat, 2 Aug 2014 00:06:22 +0800
Message-ID: <CAGb2v65yyfuJvZhYKTvROOZmumPAyLNfSGSPHeJEhSKnM9ELrA@mail.gmail.com>
References: <1406574478-19343-1-git-send-email-vbridgers2013@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	vbridger@altera.com
To: Vince Bridgers <vbridgers2013@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:64344 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754745AbaHAQGn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2014 12:06:43 -0400
Received: by mail-ie0-f182.google.com with SMTP id y20so6203017ier.41
        for <netdev@vger.kernel.org>; Fri, 01 Aug 2014 09:06:42 -0700 (PDT)
In-Reply-To: <1406574478-19343-1-git-send-email-vbridgers2013@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Tue, Jul 29, 2014 at 3:07 AM, Vince Bridgers <vbridgers2013@gmail.com> wrote:
> This patch adds platform init/exit functions and modifications to support
> suspend/resume for the Altera Cyclone 5 SOC Ethernet controller. The platform
> exit function puts the controller into reset using the socfpga reset
> controller driver. The platform init function sets up the Synopsys mac by
> first making sure the Ethernet controller is held in reset, programming the
> phy mode through external support logic, then deasserts reset through
> the socfpga reset manager driver.

Sorry for the very late reply after the fact.

Is it possible to assert/deassert the reset in the driver core
suspend/resume functions, before the clock is enabled?

Since the platform hooks are called before the core resume, and after
core suspend, doing it in the core has the same order as you have in your
platform code. And the driver core already supports reset controls,
deasserting them at probe time, and asserting them when removed.

At the same time, phy_suspend/phy_resume could be moved into the driver
core as well.

After that, you only need to keep is socfpga_dwmac_init() calling
socfpga_dwmac_setup().


I did not attempt this when I added the platform code hooks, as I did not
have suspend capable hardware to test it on.

> Signed-off-by: Vince Bridgers <vbridgers2013@gmail.com>
> ---
> V3: respin for net-next after phy_suspend was exported by libphy
>     per suggestion from Florian. No changes to patch from V2 -> V3.
> V2: Address review comments - add line break before structure decl
> ---
>  .../net/ethernet/stmicro/stmmac/dwmac-socfpga.c    |   69 ++++++++++++++++++++
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |    4 ++
>  2 files changed, 73 insertions(+)
>
[...]


Cheers
ChenYu
