From: Rob Herring <rob.herring@calxeda.com>
Subject: Re: [PATCH v2 RESEND 3/6] net: calxedaxgmac: use relaxed i/o accessors
 in rx and tx paths
Date: Thu, 01 Nov 2012 10:57:03 -0500
Message-ID: <50929BCF.3070503@calxeda.com>
References: <1351766464-27354-1-git-send-email-robherring2@gmail.com> <1351766464-27354-4-git-send-email-robherring2@gmail.com> <20121101.112141.2093388998181270335.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp151.iad.emailsrvr.com ([207.97.245.151]:43000 "EHLO
	smtp151.iad.emailsrvr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992496Ab2KAQFP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2012 12:05:15 -0400
In-Reply-To: <20121101.112141.2093388998181270335.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 11/01/2012 10:21 AM, David Miller wrote:
> From: Rob Herring <robherring2@gmail.com>
> Date: Thu,  1 Nov 2012 05:41:01 -0500
> 
>> From: Rob Herring <rob.herring@calxeda.com>
>>
>> The standard readl/writel accessors involve a spinlock and cache sync
>> operation on ARM platforms with an outer cache. Only DMA triggering
>> accesses need this, so use the relaxed variants instead.
>>
>> Signed-off-by: Rob Herring <rob.herring@calxeda.com>
>> ---
>>  drivers/net/ethernet/calxeda/Kconfig |    2 +-
>>  drivers/net/ethernet/calxeda/xgmac.c |   12 ++++++------
>>  2 files changed, 7 insertions(+), 7 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/calxeda/Kconfig b/drivers/net/ethernet/calxeda/Kconfig
>> index aba435c..6a4ddf6 100644
>> --- a/drivers/net/ethernet/calxeda/Kconfig
>> +++ b/drivers/net/ethernet/calxeda/Kconfig
>> @@ -1,6 +1,6 @@
>>  config NET_CALXEDA_XGMAC
>>  	tristate "Calxeda 1G/10G XGMAC Ethernet driver"
>> -	depends on HAS_IOMEM
>> +	depends on HAS_IOMEM && ARM
>>  	select CRC32
>>  	help
>>  	  This is the driver for the XGMAC Ethernet IP block found on Calxeda
> 
> This is a regression.  Now I can't built test this driver on x86
> or sparc.
> 
> I'm not applying this series.  You can argue until the cows come home
> about why you absolutley have to add this restriction, but I simply
> don't care, this issue is too important to me.

I did first try fixing this in the ARM L2 code, but that was rejected as
well. It is a 20-30% performance difference.

It would be nice if we had unified accessors on all platforms. Are you
okay with adding "!(BLACKFIN || HEXAGON || M68K || MICROBLAZE ||
OPENRISC || S390 || SCORE || UNICORE32)"?

Or would you be okay with using __raw_readl/__raw_writel?

Rob
