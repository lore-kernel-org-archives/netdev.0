From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 0/6] Add CPTS PTP driver support
Date: Sun, 21 Oct 2012 20:46:17 +0200
Message-ID: <20121021184617.GA32627@netboy.at.omicron.at>
References: <1350427518-7230-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:52310 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932484Ab2JUSq3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Oct 2012 14:46:29 -0400
Received: by mail-we0-f174.google.com with SMTP id t9so1081030wey.19
        for <netdev@vger.kernel.org>; Sun, 21 Oct 2012 11:46:27 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1350427518-7230-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 17, 2012 at 04:15:12AM +0530, Mugunthan V N wrote:
> This patch series contains driver implementation for TI Common Platform
> Time Sync (CPTS) driver for PTP packet timestamping.
> 
> CPTS is found in following TI SoC.
> * AM335X - http://www.ti.com/litv/pdf/spruh73c
> * DM814X - http://www.ti.com/litv/pdf/sprugz8
> 
> The Common Platform Time Sync (CPTS) module is used to facilitate host
> control of time sync operations. It enables compliance with the IEEE 1588-2008
> standard for a precision clock synchronization protocol
> 
> This patch series is tested over vanilla kernel with the below patches
> http://marc.info/?l=linux-arm-kernel&m=135032863723906&w=2

I tried v3.7-rc1 plus those patches, plus this patch series, plus the
small addition of this ...

diff --git a/arch/arm/boot/dts/am33xx.dtsi b/arch/arm/boot/dts/am33xx.dtsi
index f6bea04..e0e152b 100644
--- a/arch/arm/boot/dts/am33xx.dtsi
+++ b/arch/arm/boot/dts/am33xx.dtsi
@@ -222,6 +222,7 @@
 			ale_entries = <1024>;
 			host_port_reg_ofs = <0x108>;
 			hw_stats_reg_ofs = <0x900>;
+			cpts_reg_ofs = <0xc00>;
 			bd_ram_ofs = <0x2000>;
 			bd_ram_size = <0x2000>;
 			no_bd_ram = <0>;


... and it doesn't work. 

> Tested both L2 and L4 PTP packet timestamping

Really?

With your driver I could not get either L2 or L4 time stamps to
appear. At this point, my own driver is working a lot better, and so
this just adds another reason to favor my driver, in addtion to the
points I mentioned in my other post.

Thanks,
Richard
