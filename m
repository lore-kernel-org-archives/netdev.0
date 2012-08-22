From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: stmmac mitigation and ethtool coalesce parameters
Date: Wed, 22 Aug 2012 09:14:00 +0200
Message-ID: <503486B8.7080706@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: ML netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog114.obsmtp.com ([207.126.144.137]:46557 "EHLO
	eu1sys200aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751460Ab2HVHOQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 03:14:16 -0400
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id C81ACF6
	for <netdev@vger.kernel.org>; Wed, 22 Aug 2012 07:14:01 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 6D4FF2452
	for <netdev@vger.kernel.org>; Wed, 22 Aug 2012 07:14:01 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello
I'm reworking the mitigation schema in the stmmac and removing the old
and dead STMMAC_TIMER code.

On new chips we have an HW RX-Watchdog that can be used for mitigating
the Rx-interrupts and first results look promising.

Before posting the patches I have a doubt about the ethtool coalesce
parameters to use in the driver to tune the following parameters:

- On Rx-side I have:
  a parameter that is the RI Watchdog Timer count. It indicates the
  number of system clock cycles.

- On Tx-side, the mitigation schema I'm using is based on a SW timer
  that calls the tx function (stmmac_tx) to reclaim the resource after
  transmitting the frames.
  Also there is another parameter (like a threshold) used to program
  the descriptors avoiding to set the interrupt on completion bit in
  when the frame is sent (xmit). This means that the stmmac_tx can be
  called by the ISR too.   This approach is showing really good figures
  as well.

so I wonder which are the appropriate ethtool coalesce parameters to
use? Or could I tune them by using sysfs entries?

Welcome advice.

Peppe
