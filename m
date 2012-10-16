From: "N, Mugunthan V" <mugunthanvnm@ti.com>
Subject: RE: [PATCH V2 0/7] support the cpts found on am335x devices
Date: Tue, 16 Oct 2012 16:33:55 +0000
Message-ID: <EB1619762EAF8B4E97A227FB77B7E0293E9F82F0@DBDE01.ent.ti.com>
References: <cover.1350329726.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	David Miller <davem@davemloft.net>,
	"Chemparathy, Cyril" <cyril@ti.com>,
	"Govindarajan, Sriramakrishnan" <srk@ti.com>
To: Richard Cochran <richardcochran@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:55023 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754848Ab2JPQeL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2012 12:34:11 -0400
In-Reply-To: <cover.1350329726.git.richardcochran@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Richard Cochran [mailto:richardcochran@gmail.com]
> Sent: Tuesday, October 16, 2012 1:18 AM
> To: netdev@vger.kernel.org
> Cc: linux-arm-kernel@lists.infradead.org; David Miller; Chemparathy,
> Cyril; N, Mugunthan V; Govindarajan, Sriramakrishnan
> Subject: [PATCH V2 0/7] support the cpts found on am335x devices
> 
> This patch series, based on linux-3.7-rc1 plus the fixes I posted
> today, adds support for the Common Platform Time Sync (CPTS) found on
> the popular BeagleBone. The code enables hardware time stamping and a
> PTP Hardware Clock.
> 
> Changes in V2
>    - Now uses device tree
>    - Actually works with vanilla kernel
> 
> This work has been tested using the linuxptp PTP stack, and it seems
> to be working quite well. One limitation of the hardware is that not
> possible to adjust the clock frequency. Even without with this
> capability, the driver will be still be useful for 802.1AS
> applications, since they typically use a free running clock.
> 
> There is one open issue with this driver which will hopefully soon be
> resolved. Time stamping only works on UDP packets. Although Layer 2 is
> supposed to work according to the TRM, I have not yet figured out
> how. The UDP only works when setting an undocumented bit, so maybe
> someone from TI can fill me in on this.
> 
> Thanks,
> Richard
> 
> 
> Richard Cochran (7):
>   cpsw: rename register banks to match the reference manual
>   cpsw: add missing fields to the CPSW_SS register bank.
>   cpsw: correct the CPSW_PORT register bank declaration
>   cpsw: add a common header file for regsiter declarations
>   cpts: introduce time stamping code and a PTP hardware clock.
>   cpsw: add a DT field for the cpts offset
>   cpsw: use the time stamping capabilities of the cpts
> 
>  Documentation/devicetree/bindings/net/cpsw.txt |   11 +-
>  arch/arm/boot/dts/am33xx.dtsi                  |    5 +-
>  drivers/net/ethernet/ti/Kconfig                |    8 +
>  drivers/net/ethernet/ti/Makefile               |    2 +-
>  drivers/net/ethernet/ti/cpsw.c                 |   84 ++++-
>  drivers/net/ethernet/ti/cpsw_reg.h             |   81 ++++
>  drivers/net/ethernet/ti/cpts.c                 |  468
> ++++++++++++++++++++++++
>  drivers/net/ethernet/ti/cpts.h                 |  148 ++++++++
>  include/linux/platform_data/cpsw.h             |    1 +
>  9 files changed, 788 insertions(+), 20 deletions(-)
>  create mode 100644 drivers/net/ethernet/ti/cpsw_reg.h
>  create mode 100644 drivers/net/ethernet/ti/cpts.c
>  create mode 100644 drivers/net/ethernet/ti/cpts.h
> 
> --
> 1.7.2.5

Richard

I had seen some issues with the patch series.

* CPTS will hold only LSB 32 bits of 64 bit Timer and the upper 32 bit
  time value has to be taken care by the software, but the time stamp
  which is passed to skb or PTP clock consist of only 32 bit time value
* CPTS interrupts should be utilized to service Half and Full roll over
  events as it is non sync events with respect to get/set time and PTP
  pkt Tx/Rx
* CPTS Time which is obtained from hardware is not actually a nano
  seconds as the CPTS ref clock is tied to 250MHz for AM335x.
* CPSW register mapping done in this patch series removes the CPSW
  driver support for previous version found in TI814x
* CPSW Time stamping is done only for port 0 and port 1 is not done

Regards
Mugunthan V N
