From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH] socketcan: add a driver for FlexCAN controllers.
Date: Fri, 18 Jun 2010 13:04:07 +0200
Message-ID: <4C1B52A7.3060607@grandegger.com>
References: <20100617105201.GA2015@bluebox.local>	<4C1B4098.3090800@grandegger.com>
	<4C1B4796.3060506@pengutronix.de> <4C1B4B85.3010905@grandegger.com>
	<4C1B4DF0.2090103@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4C1B4DF0.2090103-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
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

On 06/18/2010 12:44 PM, Marc Kleine-Budde wrote:
> Wolfgang Grandegger wrote:
>> On 06/18/2010 12:16 PM, Marc Kleine-Budde wrote:
>>> Wolfgang Grandegger wrote:
>>>> Hi Hans-J=FCrgen,
>>>>
>>>> On 06/17/2010 12:52 PM, Hans J. Koch wrote:
>>>>> This adds a driver for FlexCAN based CAN controllers,
>>>>> e.g. found in Freescale i.MX35 SoCs.
>>>>>
>>>>> The original version of this driver was posted by Sascha Hauer in Jul=
y 2009:
>>>>> http://kerneltrap.org/mailarchive/linux-netdev/2009/7/29/6251621
>>>>>
>>>>> I took this version, added NAPI support, and fixed some problems found
>>>>> during testing. Well, here is the result. Please review.
>>>> I briefly browsed the patch and various bits and pieces are missing or
>>>> not correctly implemented. Marc already pointed out a few of them:
>>>>
>>>> - I do not find can_put/get_echo_skb functions in the code. How is
>>>>   IFF_ECHO supposed to work?
>>> the driver uses hardware loopback
>>
>> OK, then
>>
>>   dev =3D alloc_candev(sizeof(struct flexcan_priv), 0);
>>
>> should be used (and TX_ECHO_SKB_MAX removed) in Hans-J=FCrgens driver.
>>
>>>> - Support for CAN_CTRLMODE_BERR_REPORTING and do_get_berr_counter()
>>>>   seems to be missing.
>>>>
>>>> - Make use of alloc_can_skb() and alloc_can_err_skb().
>>> the last two points are already addressed in my version of the driver.
>>
>> I do not see support for CAN_CTRLMODE_BERR_REPORTING in your driver
>> (which has nothing to do with do_get_berr_counter).
> =

> oh yes...sorry, got confused.
> =

> However I implemented CAN_CTRLMODE_BERR_REPORTING, i.e. turning of the
> bit error interrupts by default. This has the effect that no bus warning
> and bus passive interrupt was signalled.
> =

> I should add a comment to my driver.

I'm confused, CAN_CTRLMODE_BERR_REPORTING means that the user can enable
bus error reporting, which seems not be handled in the driver your sent.
See:

http://lxr.linux.no/linux/drivers/net/can/sja1000/sja1000.c#L134
http://lxr.linux.no/linux/drivers/net/can/sja1000/sja1000.c#L588

Wolfgang.
