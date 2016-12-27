From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Platform init code in stmmac_main
Date: Tue, 27 Dec 2016 11:47:03 +0000
Message-ID: <a2d43648-b661-25c8-e29a-4685c585ee74@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: "pavel@ucw.cz" <pavel@ucw.cz>,
        Niklas Cassel <niklas.cassel@axis.com>,
        Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from us01smtprelay-2.synopsys.com ([198.182.60.111]:52471 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754383AbcL0LrI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2016 06:47:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I spotted in stmmac_main.c, *_dvr_probe() function, some clocks initializations
that are related with platform based setups:


	priv->pclk = devm_clk_get(priv->device, "pclk");
	if (IS_ERR(priv->pclk)) {
		if (PTR_ERR(priv->pclk) == -EPROBE_DEFER) {
			ret = -EPROBE_DEFER;
			goto error_pclk_get;
		}
		priv->pclk = NULL;
	}
	clk_prepare_enable(priv->pclk);

	priv->stmmac_rst = devm_reset_control_get(priv->device,
						  STMMAC_RESOURCE_NAME);
	if (IS_ERR(priv->stmmac_rst)) {
		if (PTR_ERR(priv->stmmac_rst) == -EPROBE_DEFER) {
			ret = -EPROBE_DEFER;
			goto error_hw_init;
		}
		dev_info(priv->device, "no reset control found\n");
		priv->stmmac_rst = NULL;
	}
	if (priv->stmmac_rst)
		reset_control_deassert(priv->stmmac_rst);

I am using PCI based setup, so these initializations are executed since they are
in common space in stmmac_main.c. Wouldn't be better to map these clocks in
stmmac_platform? This hasn't any problem for me, but I think it would improve
code readbility.

I would like to have your opinion about the subject!

Thanks,
Joao
