From: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH v2] Fix SJA1000 command register writes on SMP systems
Date: Tue, 18 May 2010 20:56:18 +0200
Message-ID: <4BF2E2D2.8020604@hartkopp.net>
References: <4BF1A464.6070207@hartkopp.net>
	<20100517.223415.184853371.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20100517.223415.184853371.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On 18.05.2010 07:34, David Miller wrote:
> From: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
> Date: Mon, 17 May 2010 22:17:40 +0200
> 
>> diff --git a/drivers/net/can/sja1000/sja1000.c b/drivers/net/can/sja1000/sja1000.c
>> index 145b1a7..2760085 100644
>> --- a/drivers/net/can/sja1000/sja1000.c
>> +++ b/drivers/net/can/sja1000/sja1000.c
>> @@ -84,6 +84,27 @@ static struct can_bittiming_const sja1000_bittiming_const = {
>>  	.brp_inc = 1,
>>  };
>>  +static void sja1000_write_cmdreg(struct sja1000_priv *priv, u8 val)
>> +{
>> +	/* the command register needs some locking on SMP systems */
>> +
>> +#ifdef CONFIG_SMP
> 
> Something is adding spurious leading spaces to lines in your patch.

Sorry. This was probably due to the v2 resend. Will fix.

> Also, please don't SMP conditionalize this code.  It makes it such that
> lock debugging et al. can't be used to check this code on uniprocessor.

Ok.

Will send an updated v3 patch shortly.

Thanks,
Oliver
