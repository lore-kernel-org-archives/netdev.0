From: David Miller <davem@davemloft.net>
Subject: Re: [RFC:PATCH 3.6.0-] net/ipconfig: Extend ipconfig retries to
 device open
Date: Sun, 07 Oct 2012 00:11:56 -0400 (EDT)
Message-ID: <20121007.001156.294004123796199582.davem@davemloft.net>
References: <1349365123-25826-1-git-send-email-srinivas.kandagatla@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: srinivas.kandagatla@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39580 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750720Ab2JGEMA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Oct 2012 00:12:00 -0400
In-Reply-To: <1349365123-25826-1-git-send-email-srinivas.kandagatla@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
Date: Thu,  4 Oct 2012 16:38:43 +0100

> This patch adds retries to ipconfig at device open, the reason to do
> this is: Lets say If some mdio bus driver decide to use defered probe
> when it does not find any phys on the bus. The same mdio-bus driver is
> re-probed as part of lateinit calls. However ipconfig also fits into
> lateinit calls, so if ipconfig is called before the re-probe of mdio-bus
> driver, the mac driver will fail to find a valid PHY on the mdio-bus.

Real device drivers for real devices should not probe using late
initcalls.

The whole point of late initcalls is that you can be certain that they
run after such things.

Fix the virus not the symptom.

I'm not applying this patch.
