From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [net-2.6.24] forcedeth does not compile without	CONFIG_FORCEDETH_NAPI
 set
Date: Tue, 14 Aug 2007 19:22:48 +0200
Message-ID: <46C1E4E8.2@hartkopp.net>
References: <46BCA18B.80603@hartkopp.net> <20070812132853.GA3851@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Samuel Ortiz <samuel@sortiz.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:49209 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751552AbXHNRWy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2007 13:22:54 -0400
In-Reply-To: <20070812132853.GA3851@sortiz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Samuel Ortiz wrote:
> Hi Oliver,
>
> On Fri, Aug 10, 2007 at 07:34:03PM +0200, Oliver Hartkopp wrote:
>   
>> Checking some other source with the current net-2.6.24 GIT, i just
>> discovered this:
>>
>>   CC      drivers/net/mii.o
>>   CC      drivers/net/Space.o
>>   CC      drivers/net/loopback.o
>>   CC      drivers/net/b44.o
>>   CC      drivers/net/forcedeth.o
>> drivers/net/forcedeth.c: In function nv_nic_irq:
>> drivers/net/forcedeth.c:3017: error: RX_WORK_PER_LOOP undeclared (first
>> use in this function)
>> drivers/net/forcedeth.c:3017: error: (Each undeclared identifier is
>> reported only once
>> drivers/net/forcedeth.c:3017: error: for each function it appears in.)
>> make[2]: *** [drivers/net/forcedeth.o] Error 1
>> make[1]: *** [drivers/net] Error 2
>> make: *** [drivers] Error 2
>>
>> This only occurs the CONFIG_FORCEDETH_NAPI is _disabled_.
>>     
> This fixes the build:
>
> --
> Signed-off-by: Samuel Ortiz <samuel@sortiz.org>
>
>  drivers/net/forcedeth.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
> index 37732f9..90eef4a 100644
> --- a/drivers/net/forcedeth.c
> +++ b/drivers/net/forcedeth.c
> @@ -2973,6 +2973,8 @@ static void nv_link_irq(struct net_device *dev)
>  	dprintk(KERN_DEBUG "%s: link change notification done.\n", dev->name);
>  }
>  
> +#define TX_WORK_PER_LOOP  64
> +#define RX_WORK_PER_LOOP  64
>  static irqreturn_t nv_nic_irq(int foo, void *data)
>  {
>  	struct net_device *dev = (struct net_device *) data;
> @@ -3083,8 +3085,6 @@ static irqreturn_t nv_nic_irq(int foo, void *data)
>  	return IRQ_RETVAL(i);
>  }
>  
> -#define TX_WORK_PER_LOOP  64
> -#define RX_WORK_PER_LOOP  64
>  /**
>   * All _optimized functions are used to help increase performance
>   * (reduce CPU and increase throughput). They use descripter version 3,
>
>
>
>   

Hi Samuel,

indeed a small thing that fixed the build problem :-)
Thanks for your patch & best regards,

Oliver

Acked-by: Oliver Hartkopp <oliver@hartkopp.net>



