From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH net-next v2 1/4] can: cc770: add
 driver core for the Bosch CC770 and Intel AN82527
Date: Mon, 28 Nov 2011 15:10:54 +0100
Message-ID: <4ED3966E.7080609@grandegger.com>
References: <1322214204-1121-1-git-send-email-wg@grandegger.com>
	<1322214204-1121-2-git-send-email-wg@grandegger.com>
	<4ED3704D.5020903@pengutronix.de> <4ED3922A.50704@grandegger.com>
	<4ED3941D.3070302@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, socketcan-users-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Return-path: <socketcan-users-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4ED3941D.3070302-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-users>,
	<mailto:socketcan-users-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-users>
List-Post: <mailto:socketcan-users-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-users-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-users>,
	<mailto:socketcan-users-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-users-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-users-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On 11/28/2011 03:01 PM, Marc Kleine-Budde wrote:
> On 11/28/2011 02:52 PM, Wolfgang Grandegger wrote:
> 
> [...]
> 
>>>> +/*
>>>> + * This driver uses the last 5 message objects 11..15. The definitions
>>>> + * and structure below allows to configure and assign them to the real
>>>> + * message object.
>>>> + */
>>>> +static unsigned char cc770_obj_flags[CC770_OBJ_MAX] = {
>>>> +	[CC770_OBJ_RX0] = CC770_OBJ_FLAG_RX,
>>>> +	[CC770_OBJ_RX1] = CC770_OBJ_FLAG_RX | CC770_OBJ_FLAG_EFF,
>>>> +	[CC770_OBJ_RX_RTR0] = CC770_OBJ_FLAG_RX | CC770_OBJ_FLAG_RTR,
>>>> +	[CC770_OBJ_RX_RTR1] = CC770_OBJ_FLAG_RX | CC770_OBJ_FLAG_RTR |
>>>> +			      CC770_OBJ_FLAG_EFF,
>>>> +	[CC770_OBJ_TX] = 0,
>>>> +};
>>>
>>> Is is worth the trouble making this a per device instance option? In a
>>> OF-Tree world should this become an "attribute" (or what's the correct
>>> of-tree word for it?)
>>
>> Well, only msg object 15 does have double buffering and should therefore
>> be used for bulk data reception. Therefore we have for the i82527 the
>> module parameter:
>>
>>   MODULE_PARM_DESC(msgobj15_eff,
>> 	           "Extended 29-bit frames for message object 15 "
>> 	 	   "(default: 11-bit standard frames)");
>>
>> For TX we currently use just one object. Anyway, the device tree is not
>> the right place to define such parameters because it's too static. The
>> user may want to select it at runtime depending on the application, if
>> at all. We can change it when there is a *real* requirement.
> 
> Fine with me.
> 
>>>> +	for (o = 0; o <  CC770_OBJ_MAX; o++) {
>>>                          ^^^^^^^^^^^^^
>>>
>>> what about ARRAY_SIZE(priv->obj_flags)
>>
>> CC770_OBJ_MAX is not derived from a static array definition but as show
>> below:
> 
> Okay...
> 
>>   enum {
>> 	CC770_OBJ_RX0 = 0,	/* for receiving normal messages */
>> 	CC770_OBJ_RX1,		/* for receiving normal messages */
>> 	CC770_OBJ_RX_RTR0,	/* for receiving remote transmission requests */
>> 	CC770_OBJ_RX_RTR1,	/* for receiving remote transmission requests */
>> 	CC770_OBJ_TX,		/* for sending messages */
>> 	CC770_OBJ_MAX  <================
> 
> ...then add a "," here :P

Why?

Wolfgang.
