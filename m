From: Niklas Cassel <niklas.cassel@axis.com>
Subject: stmmac CBS configuration for TX AVB queue
Date: Fri, 31 Mar 2017 11:59:46 +0200
Message-ID: <3ba8014e-aa49-1c70-a635-11c0b2a84fc2@axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Joao Pinto <Joao.Pinto@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bastet.se.axis.com ([195.60.68.11]:55546 "EHLO
        bastet.se.axis.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932875AbdCaJ7u (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 31 Mar 2017 05:59:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Joao


I was looking at

commit 19d9187317979cf0c25f67017d2676149abc46b2
Author: Joao Pinto <Joao.Pinto@synopsys.com>
Date:   Fri Mar 10 18:24:59 2017 +0000

    net: stmmac: configuration of CBS in case of a TX AVB queue
    
    This patch adds the configuration of the AVB Credit-Based Shaper.



It looks to me that we loop through all txqueues (including 0)

static void stmmac_configure_cbs(struct stmmac_priv *priv)
...
    for (queue = 0; queue < tx_queues_count; queue++) {
        ...
        priv->hw->mac->config_cbs(...)


then in

static void dwmac4_config_cbs(..)
...
    value = readl(ioaddr + MTL_ETSX_CTRL_BASE_ADDR(queue));


The MTL_ETSX_CTRL_BASE_ADDR register only exists for txqueues != 0.
(Since txqueue0 will always handle legacy traffic.)

I think that we need to make sure that we do not enter
config_cbs() for txqueue0, even if the user's device tree
has txqueue0 set to AVB, since MTL_ETSX_CTRL_BASE_ADDR
will evaluate to a non-existing register for txqueue0.

Perhaps also clarify how we expect the user to configure
his device tree for txqueue0 when using AVB in:
Documentation/devicetree/bindings/net/stmmac.txt


Best regards,
Niklas
