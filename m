From: Aida Mynzhasova <aida.mynzhasova@skitlab.ru>
Subject: Device tree node for Freescale Gianfar PTP reference clock source
 selection
Date: Mon, 23 Sep 2013 11:37:49 +0400
Message-ID: <523FEFCD.70409@skitlab.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	Richard Cochran <richardcochran@gmail.com>,
	Claudiu Manoil <claudiu.manoil@freescale.com>
To: linuxppc-dev@lists.ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.skitlab.ru ([217.65.220.135]:42823 "EHLO mail.skitlab.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753179Ab3IWHhv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Sep 2013 03:37:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Currently, Freescale Gianfar PTP reference clock source is determined 
through hard-coded value in gianfar_ptp driver. I don't think that 
recompilation of the entire module (or even worse - the kernel) is a god 
idea when we want to change one clock source to another. So, I want to 
add new device tree binding, which can be used as:

	ptp_clock@24E00 {
		compatible = "fsl,etsec-ptp";
		reg = <0x24E00 0xB0>;
		interrupts = <12 0x8 13 0x8>;
		interrupt-parent = < &ipic >;
		fsl,cksel = <0>; /* <-- New entry */
		fsl,tclk-period = <10>;
		fsl,tmr-prsc    = <100>;
		fsl,tmr-add     = <0x999999A4>;
		fsl,tmr-fiper1  = <0x3B9AC9F6>;
		fsl,tmr-fiper2  = <0x00018696>;
		fsl,max-adj     = <659999998>;
	};

fsl,cksel acceptable values:

<0> for external clock;
<1> for eTSEC system clock;
<2> for eTSEC1 transmit clock;
<3> for RTC clock input.

I am new in this mailing list, and as far as I know, I have to discuss 
all updates for device tree files here before sending patch, which uses 
new attributes.

Also, should I define new bindings in some special way? I want to add 
description of cksel attribute in 
/Documentation/devicetree/bindings/net/fsl-tsec-phy.txt. Is it enough or 
not?

Thanks!

-- 
Regards,
Aida
