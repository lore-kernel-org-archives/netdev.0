From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [MeeGo-Dev][PATCH] Topcliff: Update PCH_CAN driver to 2.6.35
Date: Mon, 13 Sep 2010 14:29:12 +0200
Message-ID: <4C8E1918.5000007@pengutronix.de>
References: <4C61EDE5.4030505@dsn.okisemi.com>	<4C629FE5.6000204@pengutronix.de>
	<005f01cb533e$5c21d530$66f8800a@maildom.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	gregkh-l3A5Bk7waGM@public.gmane.org, yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	Morinaga <morinaga526-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>, meego-dev-WXzIur8shnEAvxtiuMwx3w@public.gmane.org,
	arjan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: Masayuki Ohtake <masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <005f01cb533e$5c21d530$66f8800a-a06+6cuVnkTSQfdrb5gaxUEOCMrvLtNR@public.gmane.org>
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

On 09/13/2010 02:07 PM, Masayuki Ohtake wrote:
>> - Try to send patches directly with git send-email
> In our network environment, we can't use send-email.

that's bad...talk to your IT department :)

>> - don't use global variables
> I have modified so that our patch doesn't use global variable except module parameter.
>
>> - don't use that "int handle", e.g.:
> I have deleted.
>
>
>> - get rid of the intermediate struct pch_can_msg:
>>    Your data path is:
>>    struct can_frame ->  struct pch_can_msg ->  registers
>>    write from struct can_frame into registers directly
> Since Topcliff CAN HW register assign is different from struct can_frame,
> I think intermediate structure is necessary.

I don't see any reason for this. No other driver has an intermediate 
struct. Look at the other drivers.

>> - what's the purpose of "p_can_os->can_callback", call the function
>>    directly from the interrupt handler
> I have deleted
>
>> - implement NAPI
> Since Topcliff CAN HW register has only single rx buffer,
> I think NAPI is unnecessary.

Doesn't matter. Please try to implement it.

>> - get rid of "1<<  BIT_SHIFT_SIX" and friend,
>>    use "1<<  6" or "BIT(6)" if you like defines
> I have modified.
>
>> - use defines to set bits in struct can_frame can_id
> I have modified.
>
> I will resubmit modified our CAN patch soon.
>
> Thanks, Ohtake(OKISemi)

cheers, Marc

-- 
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |
