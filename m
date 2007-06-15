From: Geoff Levand <geoffrey.levand@am.sony.com>
Subject: Re: [PATCH]: ps3: gigabit ethernet driver for PS3
Date: Fri, 15 Jun 2007 10:16:41 -0700
Message-ID: <4672C979.8040609@am.sony.com>
References: <20070613154156.71DB.MOKUNO@sm.sony.co.jp> <46705334.5060001@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: MOKUNO Masakazu <mokuno@sm.sony.co.jp>, netdev@vger.kernel.org,
	Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>,
	davem@davemloft.net
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound-blu.frontbridge.com ([65.55.251.16]:2771 "EHLO
	outbound8-blu-R.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750724AbXFORQp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jun 2007 13:16:45 -0400
In-Reply-To: <46705334.5060001@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> MOKUNO Masakazu wrote:
>> +config GELIC_NET
>> +	tristate "PS3 Gigabit Ethernet driver"
>> +	depends on PPC_PS3
>> +	help
>> +	  This driver supports the Gigabit Ethernet device on the
>> +	  PS3 game console.
>> +
>> +	  To compile this driver as a module, choose M here: the
>> +	  module will be called ps3_gelic.
>> +
>>  config GIANFAR
>>  	tristate "Gianfar Ethernet"
>>  	depends on 85xx || 83xx || PPC_86xx
>> --- a/drivers/net/Makefile
>> +++ b/drivers/net/Makefile
>> @@ -60,6 +60,8 @@ obj-$(CONFIG_TIGON3) += tg3.o
>>  obj-$(CONFIG_BNX2) += bnx2.o
>>  spidernet-y += spider_net.o spider_net_ethtool.o
>>  obj-$(CONFIG_SPIDER_NET) += spidernet.o sungem_phy.o
>> +obj-$(CONFIG_GELIC_NET) += ps3_gelic.o
>> +ps3_gelic-objs += gelic_net.o
>>  obj-$(CONFIG_TC35815) += tc35815.o
>>  obj-$(CONFIG_SKGE) += skge.o
>>  obj-$(CONFIG_SKY2) += sky2.o
> 
> How about ps3_gige for the driver name.  Ditto DaveM's comments about 
> cleanups here.

Hi Jeff.  

Based on your comments and those from Dave, I feel I need to explain a
little about our system and what we plan for the network support.

First about the name.  The name 'gelic' comes from the underlying
device's name.  The name 'gelic' is already a well known in public
to be the PS3's network device (try google), so I think ps3_gelic
is a good name to use here.

Regarding the device, Mokuno-san already mentioned it, but this
is a virtual device which supports both Ether and wireless, so
it is more that just an Ethernet device (I think we can change
the Kconfig text to be more accurate).

Now, about the driver.  We have arranged the driver so that
the wireless support can be enabled by a config option.  So
when CONFIG_GELIC_WIRELESS=n you get ps3_gelic.ko with just
Ether support, and when CONFIG_GELIC_WIRELESS=y, you get
ps3_gelic.ko with both Ether and wireless support.  So in
the makefile we would like to have this:

  obj-$(CONFIG_GELIC_NET) += ps3_gelic.o
  gelic-$(CONFIG_GELIC_WIRELESS) += gelic_wireless.o
  ps3_gelic-objs += gelic_net.o $(gelic-y)

This all seems fine, but what is causing us trouble is that
during the review of the wireless part Dan Williams made many
non-trivial recommendations, and so we decided we need to re-work
the wireless and it won't be ready for 2.6.23. So, to avoid having 
to either change module names, or change file names when we submit
the wireless part for 2.6.24, we would like to have this for 2.6.23:

  obj-$(CONFIG_GELIC_NET) += ps3_gelic.o
  ps3_gelic-objs += gelic_net.o

Does it make sense?  If you have a better idea, please let us know.

-Geoff

