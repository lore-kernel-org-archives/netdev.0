From: Marek Vasut <marex@denx.de>
Subject: Re: [RFC][PATCH] net: stmmac: Call custom init from stmmac_dvr_probe
Date: Mon, 25 Apr 2016 12:36:05 +0200
Message-ID: <571DF315.9070204@denx.de>
References: <1461240748-5464-1-git-send-email-marex@denx.de> <CAGhQ9Vz=ipQzGOd3XZtU4MjgMqAMqvo3_naTUGcK-2a6NNDwLQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"peppe.cavallaro" <peppe.cavallaro@st.com>,
	alexandre.torgue@st.com,
	Maxime Ripard <maxime.ripard@free-electrons.com>,
	Chen-Yu Tsai <wens@csie.org>,
	Matthew Gerlach <mgerlach@opensource.altera.com>,
	Dinh Nguyen <dinguyen@opensource.altera.com>,
	"David S . Miller" <davem@davemloft.net>
To: Joachim Eastwood <manabian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:33770 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752322AbcDYLB4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 07:01:56 -0400
In-Reply-To: <CAGhQ9Vz=ipQzGOd3XZtU4MjgMqAMqvo3_naTUGcK-2a6NNDwLQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/25/2016 08:30 AM, Joachim Eastwood wrote:
> Hi Marek,
> 
> On 21 April 2016 at 14:12, Marek Vasut <marex@denx.de> wrote:
>> Each and every driver which implements custom plat_data->init function
>> calls it exactly before stmmac_dvr_probe(). Trim down the code duplication
>> by calling the plat_data->init function from stmmac_dvr_probe() instead.
> 
> This is a result of my refactoring that started a long time ago, but
> the cleanup after this is still missing. I have a patch set that
> removes the init/exit callbacks from most of the drivers and replace
> them with proper PM and remove callbacks. Patches can be found here:
> https://github.com/manabian/linux-lpc/tree/net-next-dwmac. Note that
> the branch is outdated now and needs to be rebased.
> 
> Sadly I haven't had much time to work on this lately. One of reason
> why I want to get rid of the init/exit callback is that it kinda
> forces the driver to call the same code for probe/resume and
> remove/suspend. This does not work for all drivers and this has to
> worked around in some drivers. In the end the dwmac drivers will look
> more standard Linux drivers and the stmmac will be used as library
> that drivers call into. Note that for "legacy" platforms which use the
> generic driver I intend to keep the init/exit callbacks since they are
> still used by Blackfin and Loongson, but new DT enabled drivers should
> not use these callbacks anymore.
> 
> If you are willing to test my patch set for dwmac-socfpga(?). I'll see
> if I can create the time to send them to netdev early this week.

Sure, if you also push a branch against linux/next or something close,
it'd make things easier for me, since I won't have to pick the patches
from the ML by hand.

Thanks!
-- 
Best regards,
Marek Vasut
