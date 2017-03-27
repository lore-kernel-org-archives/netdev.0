From: Bjorn Andersson <bjorn.andersson@linaro.org>
Subject: Re: [PATCH 1/3] soc: qcom: smd: Transition client drivers from smd
 to rpmsg
Date: Mon, 27 Mar 2017 15:58:37 -0700
Message-ID: <20170327225836.GL20094@minitux>
References: <20170320233544.1656-1-bjorn.andersson@linaro.org>
 <20170322.114439.679826829857326050.davem@davemloft.net>
 <20170322215733.GH20094@minitux>
 <20170323.165613.802100008000968298.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: marcel@holtmann.org, gustavo@padovan.org, johan.hedberg@gmail.com,
        k.eugene.e@gmail.com, kvalo@codeaurora.org, andy.gross@linaro.org,
        david.brown@linaro.org, arnd@arndb.de,
        linux-bluetooth@vger.kernel.org, linux-kernel@vger.kernel.org,
        wcn36xx@lists.infradead.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-arm-msm@vger.kernel.org,
        linux-soc@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170323.165613.802100008000968298.davem@davemloft.net>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu 23 Mar 16:56 PDT 2017, David Miller wrote:

> From: Bjorn Andersson <bjorn.andersson@linaro.org>
> Date: Wed, 22 Mar 2017 14:57:33 -0700
> 
> > On Wed 22 Mar 11:44 PDT 2017, David Miller wrote:
> > 
> >> From: Bjorn Andersson <bjorn.andersson@linaro.org>
> >> Date: Mon, 20 Mar 2017 16:35:42 -0700
> >> 
> >> What is the status of the Kconfig dependency fix and how will I be
> >> getting it?
> >> 
> > 
> > There are two Kconfig dependencies in play here, the first is
> > c3104aae5d8c ("remoteproc: qcom: fix QCOM_SMD dependencies"), this was
> > picked up by Linus yesterday and will as such be in v4.10-rc4.
> > 
> > The other dependency, is the one Marcel wants you to pick up here is
> > https://patchwork.kernel.org/patch/9635385/. It's on LKML, but if you
> > want I can resend it with you as direct recipient, with Marcel's ack.
> > 
> > Likely Arnd would like this fix to be sent upstream for v4.11 already.
> > 
> >> Second, should I merge all three of these patches to net-next or just
> >> this one?
> >> 
> > 
> > I would like all three to be merged in this cycle and in addition I have
> > a couple of patches coming up that will cause some minor conflicts with
> > patch 2 - so I would prefer if patch 2 was available in a tag I can
> > merge into my tree.
> 
> I should have all the dependencies in net-next now, but when I apply
> this series I get undefined symbols:
> 

I'm sorry, but I can't figure out how to reproduce this. I took the
master branch of net-next and applied the three patches in this series.

> [davem@localhost net-next]$ time make -s -j8
> Kernel: arch/x86/boot/bzImage is ready  (#578)
> ERROR: "qcom_rpm_smd_write" [drivers/regulator/qcom_smd-regulator.ko] undefined!

According to drivers/regulator/Kconfig REGULATOR_QCOM_SMD_RPM depends on
QCOM_SMD_RPM and there's nothing tricky here. So if the Kconfig
dependency is met you should have qcom_rpm_smd_write().

> ERROR: "qcom_wcnss_open_channel" [drivers/net/wireless/ath/wcn36xx/wcn36xx.ko] undefined!

WCN36XX depends on QCOM_WCNSS_CTRL || QCOM_WCNSS_CTRL=n, in other words
either qcom_wcnss_open_channel() should be defined from
drivers/soc/qcom/wcnss_ctrl.o (or .ko) or be stubbed by
include/linux/soc/qcom/wcnss_ctrl.h

> ERROR: "qcom_rpm_smd_write" [drivers/clk/qcom/clk-smd-rpm.ko] undefined!

As with REGULATOR_QCOM_SMD_RPM, this depends on QCOM_SMD_RPM - so it
should be covered.

> ERROR: "qcom_wcnss_open_channel" [drivers/bluetooth/btqcomsmd.ko] undefined!

This is the problem that was corrected by  6e9e6cc8f4e4 ("Bluetooth:
btqcomsmd: fix compile-test dependency") and with the same dependencies
as CONFIG_WCN36XX I don't see how this can happen (with that patch
applied).

> scripts/Makefile.modpost:91: recipe for target '__modpost' failed
> 
> Please fix this up.

Can you please help me figure this out?

Perhaps you can help me figure it out by letting me know the state of
the following config options in your local .config?

CONFIG_QCOM_SMD_RPM
CONFIG_QCOM_WCNSS_CTRL
CONFIG_REGULATOR_QCOM_SMD_RPM
CONFIG_RPMSG
CONFIG_WCN36XX

I'm sorry for the inconvenience.

Regards,
Bjorn
