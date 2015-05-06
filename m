From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] stmmac: call local_irq_save other than disable_irq in
 poll_controller
Date: Wed, 06 May 2015 10:02:06 -0400 (EDT)
Message-ID: <20150506.100206.330276176302097173.davem@davemloft.net>
References: <1430812553-7588-1-git-send-email-sonic.adi@gmail.com>
	<20150505.193633.2161230945632055751.davem@davemloft.net>
	<CAJxxZ0Oi_xLA3PY4Phb6q+J-2FeO6tvVyD0viTAdXVWVQm1V-g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	adi-buildroot-devel@lists.sourceforge.net, sonic.zhang@analog.com
To: sonic.adi@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36817 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752840AbbEFOCH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 10:02:07 -0400
In-Reply-To: <CAJxxZ0Oi_xLA3PY4Phb6q+J-2FeO6tvVyD0viTAdXVWVQm1V-g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sonic Zhang <sonic.adi@gmail.com>
Date: Wed, 6 May 2015 11:53:53 +0800

> When I debug Linux kernel via KGDB over Ethernet, KGDB calls netpoll
> API and stmmac_poll_controller to send UDP packets with all interrupts
> disabled. KGDB assumes all interrupts keeps disabled when it is active
> and doing UDP data transmission. Enabling interrupts in
> stmmac_poll_controller causes KGDB re-enter exception and system halt.

If KGDB has disabled local cpu interrupts, that cannot happen.

What stmmac_poll_controller() is doing is enabling a specific interupt
source, not "interrupts" generally.  The latter is what KGDB can
specifically control and should care about.
