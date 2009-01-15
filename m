From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH] fec: Add mx2 support (WIP)
Date: Thu, 15 Jan 2009 11:15:27 +0100
Message-ID: <20090115101527.GR11228@pengutronix.de>
References: <1231949353-29630-1-git-send-email-s.hauer@pengutronix.de> <1231949353-29630-2-git-send-email-s.hauer@pengutronix.de> <1231949353-29630-3-git-send-email-s.hauer@pengutronix.de> <1231949353-29630-4-git-send-email-s.hauer@pengutronix.de> <1231949353-29630-5-git-send-email-s.hauer@pengutronix.de> <1231949353-29630-6-git-send-email-s.hauer@pengutronix.de> <1231949353-29630-7-git-send-email-s.hauer@pengutronix.de> <496EE42D.4040300@snapgear.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Sebastian Siewior <bigeasy@linutronix.de>
To: Greg Ungerer <gerg@snapgear.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:40238 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760461AbZAOKP3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 05:15:29 -0500
Content-Disposition: inline
In-Reply-To: <496EE42D.4040300@snapgear.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Greg,

On Thu, Jan 15, 2009 at 05:22:21PM +1000, Greg Ungerer wrote:
> Hi Sascha,
>
> Sascha Hauer wrote:
>> Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>
>> ---
>>  drivers/net/Kconfig |    2 +-
>>  drivers/net/fec.c   |  121 +++++++++++++++++++++++++++++++++++++++++++++++++--
>>  drivers/net/fec.h   |   11 ++++-
>>  3 files changed, 127 insertions(+), 7 deletions(-)
>>
>> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
>> @@ -1109,7 +1125,14 @@ static phy_info_t const phy_info_am79c874 = {
>>  /* register definitions for the 8721 */
>>   #define MII_KS8721BL_RXERCR	21
>> +#ifdef CONFIG_ARCH_MX2
>> + /* FIXME: is this a bug or board specific?
>> +  * 27 was found somewhere in the Freescale code
>> +  */
>> +#define MII_KS8721BL_ICSR	27
>> +#else
>>  #define MII_KS8721BL_ICSR	22
>> +#endif

I have just found the datasheet for this chip. The ICSR register is
indeed on 27, not on 22. So this is a bug in the driver. I will make a
seperate patch from this hunk.

>>  #define	MII_KS8721BL_PHYCR	31
>>   static phy_cmd_t const phy_cmd_ks8721bl_config[] = {
>> @@ -1698,6 +1721,95 @@ static void __inline__ fec_phy_ack_intr(void)
>>  {
>>  }
>>  +#elif defined(CONFIG_ARCH_MX2)
>> +
>> +/*
>> + * do some initializtion based architecture of this chip
>> + */
>> +static void inline fec_arch_init(void)
>> +{
>> +	struct clk *clk;
>> +	clk = clk_get(NULL, "fec_clk");
>> +	clk_enable(clk);
>> +	clk_put(clk);
>> +	return;
>> +}
>
> ColdFire builds break on fec_arch_init(), since it is only
> defined for ARCH_MX2.

Ok, I'll leave this one out and put it in my board file for now.

Regards
  Sascha

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
