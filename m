From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Driver SFC: Possible bug in LM87 temperature XFP detection code
Date: Tue, 28 Apr 2009 14:36:39 +0100
Message-ID: <1240925799.3200.16.camel@achroite>
References: <1240911369.10689.20.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jesper Dangaard Brouer <hawk@comx.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:34052 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754816AbZD1Ngq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2009 09:36:46 -0400
In-Reply-To: <1240911369.10689.20.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-04-28 at 11:36 +0200, Jesper Dangaard Brouer wrote:
> Hi Ben,
> 
> I have borrowed some SMC10GPCIe-XFP NICs directly from SMC for
> evaluation.  The NICs uses a Solarflare Chip and the SFC driver.
> 
> If unpluging the fiber cable I start getting these errors:
> 
> +--------
>  sfc 0000:12:00.0: ERR: eth88 LM87 detected a hardware failure (status 30:00) INTERNAL EXTERNAL
>  sfc 0000:12:00.0: ERR: eth88 Board sensor reported fault; shutting down PHY
> 
>  sfc 0000:12:00.0: ERR: eth88 LM87 detected a hardware failure (status 30:00) INTERNAL EXTERNAL
>  sfc 0000:12:00.0: ERR: eth88 Board sensor reported fault; shutting down PHY
> 
>  sfc 0000:12:00.0: ERR: eth88 LM87 detected a hardware failure (status 10:00) INTERNAL
>  sfc 0000:12:00.0: ERR: eth88 Board sensor reported fault; shutting down PHY
> +---------
> 
> Reading through the driver code (drivers/net/sfc/boards.c), this problem
> is related to temperature.

Right.  And the sensors are not polled while the link is up, on the
assumption that a temperature or voltage fault will cause the link to go
down, and because bit-banged I2C will reduce throughput slightly.

> The real issues is that I cannot get the device up and running again
> after lowering the temperature.  Only if I unload and load the sfc
> driver, then I can get the device running again.
> 
> I'm thinking perhaps there is missing a PHY power up again, after the
> temperature alarm has gone?

We considered it most important to shut down the board to prevent or
mitigate damage, and did not implement any recovery beyond that.

> I'm using kernel 2.6.30-rc1-net-next-00664-gd93fe1a.
> 
> 
> To Ben; do you have anything you want me to try. Do you want to fix this
> you self, or can you give me some code hints or patches to try out?

I don't intend to fix this myself.  If you want to try implementing this
then you should start by looking at efx_monitor() in efx.c.  However, I
think your time might be better spent in fixing the air flow in the
computer before the board is permanently damaged.

> I'm wondering what chip the SMC NIC is using? From lspci is says
> SFC4000, but does that corrospond to EFX_BOARD_SFE4001 or
> EFX_BOARD_SFE4002 ?

The SMC10GPCIe-XFP is based on SFE4002.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

