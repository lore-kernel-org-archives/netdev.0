From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/2] ravb: add wake-on-lan support via magic packet
Date: Tue, 01 Aug 2017 17:54:56 -0700 (PDT)
Message-ID: <20170801.175456.1013679579280658399.davem@davemloft.net>
References: <20170801101437.9020-1-niklas.soderlund+renesas@ragnatech.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: sergei.shtylyov@cogentembedded.com, geert@linux-m68k.org,
        netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
To: niklas.soderlund+renesas@ragnatech.se
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <20170801101437.9020-1-niklas.soderlund+renesas@ragnatech.se>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Niklas Söderlund <niklas.soderlund+renesas@ragnatech.se>
Date: Tue,  1 Aug 2017 12:14:35 +0200

> WoL is enabled in the suspend callback by setting MagicPacket detection
> and disabling all interrupts expect MagicPacket. In the resume path the
> driver needs to reset the hardware to rearm the WoL logic, this prevents
> the driver from simply restoring the registers and to take advantage of
> that ravb was not suspended to reduce resume time. To reset the
> hardware the driver closes the device, sets it in reset mode and reopens
> the device just like it would do in a normal suspend/resume scenario
> without WoL enabled, but it both closes and opens the device in the
> resume callback since the device needs to be reset for WoL to work.
> 
> One quirk needed for WoL is that the module clock needs to be prevented
> from being switched off by Runtime PM. To keep the clock alive the
> suspend callback need to call clk_enable() directly to increase the
> usage count of the clock. Then when Runtime PM decreases the clock usage
> count it won't reach 0 and be switched off.
> 
> Changes since v2
> - Only do the clock dance to workaround PSCI sleep when resuming if WoL 
>   is enabled. This was a bug in v2 which resulted in a WARN if resuming 
>   from PSCI sleep with WoL disabled, thanks Sergei for pointing this 
>   out!
> - Break out clock dance workaround in separate patch to make it easier 
>   to revert once a fix is upstream for the clock driver as suggested by 
>   Sergei.
> 
> Changes since v1
> - Fix issue where device would fail to resume from PSCI suspend if WoL
>   was enabled, reported by Geert. The fault was that the clock driver
>   thinks the clock is on, but PSCI have disabled it, added workaround
>   for this in ravb driver which can be removed once the clock driver is
>   aware of the PSCI behavior.
> - Only try to restore from wol wake up if netif is running, since this
>   is a condition to enable wol in the first place this was a bug in v1.

Series applied, thanks.
