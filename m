From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [net-next:master 92/95] drivers/net/ethernet/broadcom/genet/bcmgenet.c:527:30-56:
 duplicated argument to && or ||
Date: Fri, 18 Sep 2015 09:47:18 +0200 (CEST)
Message-ID: <alpine.DEB.2.10.1509180946350.2468@hadrien>
References: <201509181511.Gm3BfYBv%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: kbuild-all@01.org, netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3-relais-sop.national.inria.fr ([192.134.164.104]:28498
	"EHLO mail3-relais-sop.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751006AbbIRHrV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 03:47:21 -0400
In-Reply-To: <201509181511.Gm3BfYBv%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Two uses of ec->tx_coalesce_usecs_high.  Please check.

julia

On Fri, 18 Sep 2015, kbuild test robot wrote:

> TO: Florian Fainelli <f.fainelli@gmail.com>
> CC: kbuild-all@01.org
> CC: netdev@vger.kernel.org
>
> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
> head:   47bbbb30b4331ec58a74a66a044341f0114b02b3
> commit: 2f9130709d2c19e2eef336bda0fb0c807cbc1f64 [92/95] net: bcmgenet: Implement TX coalescing control knobs
> :::::: branch date: 2 hours ago
> :::::: commit date: 2 hours ago
>
> >> drivers/net/ethernet/broadcom/genet/bcmgenet.c:527:30-56: duplicated argument to && or ||
>
> git remote add net-next https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git
> git remote update net-next
> git checkout 2f9130709d2c19e2eef336bda0fb0c807cbc1f64
> vim +527 drivers/net/ethernet/broadcom/genet/bcmgenet.c
>
> 2f913070 Florian Fainelli 2015-09-16  511  }
> 2f913070 Florian Fainelli 2015-09-16  512
> 2f913070 Florian Fainelli 2015-09-16  513  static int bcmgenet_set_coalesce(struct net_device *dev,
> 2f913070 Florian Fainelli 2015-09-16  514  				 struct ethtool_coalesce *ec)
> 2f913070 Florian Fainelli 2015-09-16  515  {
> 2f913070 Florian Fainelli 2015-09-16  516  	struct bcmgenet_priv *priv = netdev_priv(dev);
> 2f913070 Florian Fainelli 2015-09-16  517  	unsigned int i;
> 2f913070 Florian Fainelli 2015-09-16  518
> 2f913070 Florian Fainelli 2015-09-16  519  	if (ec->tx_max_coalesced_frames > DMA_INTR_THRESHOLD_MASK ||
> 2f913070 Florian Fainelli 2015-09-16  520  	    ec->tx_max_coalesced_frames == 0)
> 2f913070 Florian Fainelli 2015-09-16  521  		return -EINVAL;
> 2f913070 Florian Fainelli 2015-09-16  522
> 2f913070 Florian Fainelli 2015-09-16  523  	/* GENET TDMA hardware does not support a configurable timeout, but will
> 2f913070 Florian Fainelli 2015-09-16  524  	 * always generate an interrupt either after MBDONE packets have been
> 2f913070 Florian Fainelli 2015-09-16  525  	 * transmitted, or when the ring is emtpy.
> 2f913070 Florian Fainelli 2015-09-16  526  	 */
> 2f913070 Florian Fainelli 2015-09-16 @527  	if (ec->tx_coalesce_usecs || ec->tx_coalesce_usecs_high ||
> 2f913070 Florian Fainelli 2015-09-16  528  	    ec->tx_coalesce_usecs_irq || ec->tx_coalesce_usecs_high ||
> 2f913070 Florian Fainelli 2015-09-16  529  	    ec->tx_coalesce_usecs_low)
> 2f913070 Florian Fainelli 2015-09-16  530  		return -EOPNOTSUPP;
> 2f913070 Florian Fainelli 2015-09-16  531
> 2f913070 Florian Fainelli 2015-09-16  532  	/* Program all TX queues with the same values, as there is no
> 2f913070 Florian Fainelli 2015-09-16  533  	 * ethtool knob to do coalescing on a per-queue basis
> 2f913070 Florian Fainelli 2015-09-16  534  	 */
> 2f913070 Florian Fainelli 2015-09-16  535  	for (i = 0; i < priv->hw_params->tx_queues; i++)
>
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
>
