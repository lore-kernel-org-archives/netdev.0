From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: stmmac CBS configuration for TX AVB queue
Date: Fri, 31 Mar 2017 12:09:11 +0100
Message-ID: <148c42ea-df37-4f7d-b5b2-edf7d2bc0c48@synopsys.com>
References: <3ba8014e-aa49-1c70-a635-11c0b2a84fc2@axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: netdev <netdev@vger.kernel.org>
To: Niklas Cassel <niklas.cassel@axis.com>,
        Joao Pinto <Joao.Pinto@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from us01smtprelay-2.synopsys.com ([198.182.60.111]:47461 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932701AbdCaLMJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 31 Mar 2017 07:12:09 -0400
In-Reply-To: <3ba8014e-aa49-1c70-a635-11c0b2a84fc2@axis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Às 10:59 AM de 3/31/2017, Niklas Cassel escreveu:
> Hello Joao
> 
> 
> I was looking at
> 
> commit 19d9187317979cf0c25f67017d2676149abc46b2
> Author: Joao Pinto <Joao.Pinto@synopsys.com>
> Date:   Fri Mar 10 18:24:59 2017 +0000
> 
>     net: stmmac: configuration of CBS in case of a TX AVB queue
>     
>     This patch adds the configuration of the AVB Credit-Based Shaper.
> 
> 
> 
> It looks to me that we loop through all txqueues (including 0)
> 
> static void stmmac_configure_cbs(struct stmmac_priv *priv)
> ...
>     for (queue = 0; queue < tx_queues_count; queue++) {
>         ...
>         priv->hw->mac->config_cbs(...)
> 
> 
> then in
> 
> static void dwmac4_config_cbs(..)
> ...
>     value = readl(ioaddr + MTL_ETSX_CTRL_BASE_ADDR(queue));
> 
> 
> The MTL_ETSX_CTRL_BASE_ADDR register only exists for txqueues != 0.
> (Since txqueue0 will always handle legacy traffic.)
> 
> I think that we need to make sure that we do not enter
> config_cbs() for txqueue0, even if the user's device tree
> has txqueue0 set to AVB, since MTL_ETSX_CTRL_BASE_ADDR
> will evaluate to a non-existing register for txqueue0.
> 
> Perhaps also clarify how we expect the user to configure
> his device tree for txqueue0 when using AVB in:
> Documentation/devicetree/bindings/net/stmmac.txt
> 
> 
> Best regards,
> Niklas
> 

You are right, we did not add AVB capabilities to default/Q0, this way we
guarantee 75% bandwidth for AVB. I will send a patch soon to fix this.

Thanks,
Joao
