From: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH v3] Fix SJA1000 command register writes on SMP systems
Date: Wed, 19 May 2010 18:23:59 +0200
Message-ID: <4BF4109F.4000706@hartkopp.net>
References: <4BF2E512.1090109@hartkopp.net>
	<20100518213109.GA29894@merkur.ravnborg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: SocketCAN Core Mailing List <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: Sam Ravnborg <sam-uyr5N9Q2VtJg9hUCZPvPmw@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20100518213109.GA29894-OoSGOWW0KRunlFQ6Q1D1Y0B+6BGkLq7r@public.gmane.org>
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

On 18.05.2010 23:31, Sam Ravnborg wrote:
> Hi Oliver.
> 
>> diff --git a/drivers/net/can/sja1000/sja1000.h b/drivers/net/can/sja1000/sja1000.h
>> index 97a622b..de8e778 100644
>> --- a/drivers/net/can/sja1000/sja1000.h
>> +++ b/drivers/net/can/sja1000/sja1000.h
>> @@ -167,6 +167,7 @@ struct sja1000_priv {
>>  
>>  	void __iomem *reg_base;	 /* ioremap'ed address to registers */
>>  	unsigned long irq_flags; /* for request_irq() */
>> +	spinlock_t cmdreg_lock;  /* lock for concurrent cmd register writes */
>>  
>>  	u16 flags;		/* custom mode flags */
>>  	u8 ocr;			/* output control register */
> 
> You define your spinlock inside a struct so you cannot use
> DEFINE_SPINLOCK().
> 
> But then you need to use spin_lock_init() - which I fail to see
> you are doing in your patch.

Indeed. Sorry.

Will send a patch with spin_lock_init() e.g. to enable the spinlock debugging ...

Regards,
Oliver
