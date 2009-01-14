From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: Bad tg3 performance on S10 netbook
Date: Wed, 14 Jan 2009 15:47:45 -0800
Message-ID: <20090114234745.GA23993@xw6200.broadcom.net>
References: <496E64BB.7080709@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: "Ben Greear" <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4203 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757335AbZANXsU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2009 18:48:20 -0500
In-Reply-To: <496E64BB.7080709@candelatech.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 14, 2009 at 02:18:35PM -0800, Ben Greear wrote:
> We are testing an S10 netbook from Lenovo and it's built-in
> tg3 NIC is getting lots of 'rx-irq-missed' events and is dropping
> packets while running at about 45Mbps tx + rx.
> This is kernel 2.6.25 plus some hacks.  We did most testing
> on the stock 2.6.25 tg3 driver, but a quick attempt at using
> the latest tg3 from bcm's site shows the same irq-miss issue.
> 
> We tried forcing the cpufreq to max (1.6Ghz) and that didn't
> help much.
> 
> We tried setting the rx buffers to 511 (max for this chip it seems)
> and that didn't help.
> 
> The one thing that *does* help is to run something that eats a lot
> of CPU.  This is what made us think that the cpufreq was the issue,
> but again, hard-coding it didn't help.
> 
> We tried turning on adaptive-rx (it is off by default), and again,
> no improvement.
> 
> So, does anyone have any suggestions on what else to poke at?
> 
> Full lspci output is below.
> 
> Thanks,
> Ben

Does the following patch fix the problem?


--- 1/drivers/net/tg3.c	2008-11-10 10:50:34.000000000 -0800
+++ 2/drivers/net/tg3.c	2009-01-14 08:28:10.000000000 -0800
@@ -10709,7 +10709,7 @@ static void __devinit tg3_get_eeprom_hw_
 			tp->tg3_flags2 |= TG3_FLG2_IS_NIC;
 		}
 		val = tr32(VCPU_CFGSHDW);
-		if (val & VCPU_CFGSHDW_ASPM_DBNC)
+		/* if (val & VCPU_CFGSHDW_ASPM_DBNC) */
 			tp->tg3_flags |= TG3_FLAG_ASPM_WORKAROUND;
 		if ((val & VCPU_CFGSHDW_WOL_ENABLE) &&
 		    (val & VCPU_CFGSHDW_WOL_MAGPKT))

