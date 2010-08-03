From: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH] can-raw: Fix skb_orphan_try handling
Date: Tue, 03 Aug 2010 17:22:47 +0200
Message-ID: <4C583447.8010004@hartkopp.net>
References: <4C529EFB.4090601@hartkopp.net>	<20100801.010337.68133932.davem@davemloft.net>	<4C555168.3090800@hartkopp.net>
	<20100803.003056.216763358.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	patrick.ohly-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20100803.003056.216763358.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
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

On 03.08.2010 09:30, David Miller wrote:
> From: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
> Date: Sun, 01 Aug 2010 12:50:16 +0200
> 
>> On 01.08.2010 10:03, David Miller wrote:
>>> From: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
>>> Date: Fri, 30 Jul 2010 11:44:27 +0200
>>>
>>>> Hello Eric, hello Patrick,
>>>>
>>>> Commit fc6055a5ba31e2c14e36e8939f9bf2b6d586a7f5 (net: Introduce
>>>> skb_orphan_try()) allows an early orphan of the skb and takes care on
>>>> tx timestamping, which needs the sk-reference in the skb on driver level.
>>>> So does the can-raw socket, which has not been taken into account here.
>>>>
>>>> The patch below adds a 'prevent_sk_orphan' bit in the skb tx shared info,
>>>> which fixes the problem discovered by Matthias Fuchs here:
>>>>
>>>>       http://marc.info/?t=128030411900003&r=1&w=2
>>>
>>> Your patch sets this new value, but I never see it getting tested anywhere.
>>>
>>> How does this work?
>>
>>
>> The flags are tested all together in skb_orphan_try() ...
> 
> This is why I hate using unions in situations like this... it makes
> code impossible to audit easily.
> 
> This damn thing should just be a "u8 flags" and a bunch of bit mask
> CPP macro defines for the various boolean values.

Yep! I also felt like this.

Maybe Patrick Ohly can give some feedback, if he's ok with that kind of
change. So far there are only a few places that would need to be changed for
the flags bitops.

> Anyways, I'll apply your patch thanks.

Thanks!
