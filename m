From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v2] can: Topcliff: PCH_CAN driver:
	Fix	buildwarnings
Date: Wed, 27 Oct 2010 13:57:45 +0200
Message-ID: <4CC813B9.3080506@grandegger.com>
References: <4CC61B1B.3090602@dsn.okisemi.com>	<20101026.105206.15244527.davem@davemloft.net>	<20101026.105545.200376685.davem@davemloft.net><4CC71DA4.3020600@grandegger.com>	<4CC72360.1070608@pengutronix.de>
	<008201cb75c9$f27ff720$66f8800a@maildom.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, margie.foster-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org,
	Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>, chripell-VaTbYqLCNhc@public.gmane.org,
	morinaga526-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org, kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: Tomoya MORINAGA <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <008201cb75c9$f27ff720$66f8800a-a06+6cuVnkTSQfdrb5gaxUEOCMrvLtNR@public.gmane.org>
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

On 10/27/2010 01:27 PM, Tomoya MORINAGA wrote:
> On Wednesday, October 27, 2010 3:52 AM :  Marc Kleine-Budde and Wolfgang Grandegge wrote:
> 
> The following is some inarticulate points I have for your questions.
> Please give me more information.
> 
>> Do I understand your code correctly? You have a big loop, but only do
>>  two different things at certain values of the loop? Smells fishy.
> Uh, I can't understand your intention.
> Please show in detail.
> This processing does configuration for all message objects.

Not all, but just a few of them. We believe it can be implemented more
efficiently.

> 
>> what does this loop do? why is it nessecarry? I don't like delay loops
>>   in the hot path of a driver.
> This loop is for waiting for all tx Message Object completion.
> This is Topcliff CAN HW specification.

What do you mean with "tx Message Object completion"? Is TX done not
signaled via interrupt? Please explain why you need to wait multiples of
500us here in the hot TX path.

>> If you figured out how to use the endianess conversion functions from
>> the cpu_to_{le,be}-{le,to}_to_cpup family use them here, too.
> Uh,le32_to_cpu have been used already here.
> I can't understand your intention.
> Please show in detail.
> 
> 
>>> All these check if busy in the code make me a bit nervous, can you
>>> please explain why they are needed. A pointer to the manual is okay, too.
>> Me too. I already ask in my previous mail how long that functions
>> usually blocks.
> When accessing read/write from/to Message RAM,
> Since it takes much time for transferring between Register and Message RAM,

Much time means how many mirco-seconds?

> SW must check busy flag of CAN register.
> This is a Topcliff HW specification.

Maybe the busy check could also be done *before* the Message RAM is
accessed to avoid (or minimize) waiting.

>> is there some pdev->name instead of KBUILD_MODNAME that can be used?
> I can't understand your intention.
> pdev(struct pci_dev) doesn't have "name" member. 
> Please show in detail.

Using KBUILD_MODNAME is OK. It does hold the name of the driver as required.

Wolfgang.
