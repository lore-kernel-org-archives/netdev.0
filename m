From: "N, Mugunthan V" <mugunthanvnm@ti.com>
Subject: RE: [PATCH 0/6] Add CPTS PTP driver support
Date: Mon, 22 Oct 2012 10:51:46 +0000
Message-ID: <EB1619762EAF8B4E97A227FB77B7E0293E9FD6F5@DBDE01.ent.ti.com>
References: <1350427518-7230-1-git-send-email-mugunthanvnm@ti.com>
 <20121021184617.GA32627@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:54925 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752329Ab2JVKvy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2012 06:51:54 -0400
In-Reply-To: <20121021184617.GA32627@netboy.at.omicron.at>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Richard Cochran [mailto:richardcochran@gmail.com]
> Sent: Monday, October 22, 2012 12:16 AM
> To: N, Mugunthan V
> Cc: netdev@vger.kernel.org; davem@davemloft.net
> Subject: Re: [PATCH 0/6] Add CPTS PTP driver support
> 
> On Wed, Oct 17, 2012 at 04:15:12AM +0530, Mugunthan V N wrote:
> > This patch series contains driver implementation for TI Common
> Platform
> > Time Sync (CPTS) driver for PTP packet timestamping.
> >
> > CPTS is found in following TI SoC.
> > * AM335X - http://www.ti.com/litv/pdf/spruh73c
> > * DM814X - http://www.ti.com/litv/pdf/sprugz8
> >
> > The Common Platform Time Sync (CPTS) module is used to facilitate
> host
> > control of time sync operations. It enables compliance with the IEEE
> 1588-2008
> > standard for a precision clock synchronization protocol
> >
> > This patch series is tested over vanilla kernel with the below
> patches
> > http://marc.info/?l=linux-arm-kernel&m=135032863723906&w=2
> 
> I tried v3.7-rc1 plus those patches, plus this patch series, plus the
> small addition of this ...
> 
> diff --git a/arch/arm/boot/dts/am33xx.dtsi
> b/arch/arm/boot/dts/am33xx.dtsi
> index f6bea04..e0e152b 100644
> --- a/arch/arm/boot/dts/am33xx.dtsi
> +++ b/arch/arm/boot/dts/am33xx.dtsi
> @@ -222,6 +222,7 @@
>  			ale_entries = <1024>;
>  			host_port_reg_ofs = <0x108>;
>  			hw_stats_reg_ofs = <0x900>;
> +			cpts_reg_ofs = <0xc00>;
>  			bd_ram_ofs = <0x2000>;
>  			bd_ram_size = <0x2000>;
>  			no_bd_ram = <0>;
> 
> 
> ... and it doesn't work.
> 
> > Tested both L2 and L4 PTP packet timestamping
> 
> Really?
> 
> With your driver I could not get either L2 or L4 time stamps to
> appear. At this point, my own driver is working a lot better, and so
> this just adds another reason to favor my driver, in addtion to the
> points I mentioned in my other post.
> 

Richard

The following patch n eeds to be used to test the CPTS driver.

diff --git a/arch/arm/boot/dts/am33xx.dtsi b/arch/arm/boot/dts/am33xx.dtsi
index f6bea04..cd9b3b4 100644
--- a/arch/arm/boot/dts/am33xx.dtsi
+++ b/arch/arm/boot/dts/am33xx.dtsi
@@ -238,13 +238,13 @@
 			interrupts = <40 41 42 43>;
 			ranges;
 			cpsw_emac0: slave@0 {
-				slave_reg_ofs = <0x208>;
+				slave_reg_ofs = <0x200>;
 				sliver_reg_ofs = <0xd80>;
 				/* Filled in by U-Boot */
 				mac-address = [ 00 00 00 00 00 00 ];
 			};
 			cpsw_emac1: slave@1 {
-				slave_reg_ofs = <0x308>;
+				slave_reg_ofs = <0x300>;
 				sliver_reg_ofs = <0xdc0>;
 				/* Filled in by U-Boot */
 				mac-address = [ 00 00 00 00 00 00 ];

I have not added the above two patches in the patch series as the main
CPSW DT file patch is not accepted and not available in netdev git tree.
I have planned to post the patch series to DT mailing list soon after
the driver is accepted.

Sorry for not mentioning the same in the patch series

Regards
Mugunthan V N
