From: Joachim Eastwood <manabian@gmail.com>
Subject: Re: [RFC][PATCH] net: stmmac: Call custom init from stmmac_dvr_probe
Date: Mon, 25 Apr 2016 08:30:17 +0200
Message-ID: <CAGhQ9Vz=ipQzGOd3XZtU4MjgMqAMqvo3_naTUGcK-2a6NNDwLQ@mail.gmail.com>
References: <1461240748-5464-1-git-send-email-marex@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"peppe.cavallaro" <peppe.cavallaro@st.com>,
	alexandre.torgue@st.com,
	Maxime Ripard <maxime.ripard@free-electrons.com>,
	Chen-Yu Tsai <wens@csie.org>,
	Matthew Gerlach <mgerlach@opensource.altera.com>,
	Dinh Nguyen <dinguyen@opensource.altera.com>,
	"David S . Miller" <davem@davemloft.net>
To: Marek Vasut <marex@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:36332 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753420AbcDYGaS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 02:30:18 -0400
Received: by mail-ig0-f171.google.com with SMTP id u10so2281916igr.1
        for <netdev@vger.kernel.org>; Sun, 24 Apr 2016 23:30:18 -0700 (PDT)
In-Reply-To: <1461240748-5464-1-git-send-email-marex@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Marek,

On 21 April 2016 at 14:12, Marek Vasut <marex@denx.de> wrote:
> Each and every driver which implements custom plat_data->init function
> calls it exactly before stmmac_dvr_probe(). Trim down the code duplication
> by calling the plat_data->init function from stmmac_dvr_probe() instead.

This is a result of my refactoring that started a long time ago, but
the cleanup after this is still missing. I have a patch set that
removes the init/exit callbacks from most of the drivers and replace
them with proper PM and remove callbacks. Patches can be found here:
https://github.com/manabian/linux-lpc/tree/net-next-dwmac. Note that
the branch is outdated now and needs to be rebased.

Sadly I haven't had much time to work on this lately. One of reason
why I want to get rid of the init/exit callback is that it kinda
forces the driver to call the same code for probe/resume and
remove/suspend. This does not work for all drivers and this has to
worked around in some drivers. In the end the dwmac drivers will look
more standard Linux drivers and the stmmac will be used as library
that drivers call into. Note that for "legacy" platforms which use the
generic driver I intend to keep the init/exit callbacks since they are
still used by Blackfin and Loongson, but new DT enabled drivers should
not use these callbacks anymore.

If you are willing to test my patch set for dwmac-socfpga(?). I'll see
if I can create the time to send them to netdev early this week.


regards,
Joachim Eastwood
