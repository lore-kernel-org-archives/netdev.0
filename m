From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [MeeGo-Dev][PATCH] Topcliff: Update PCH_CAN driver to 2.6.35
Date: Wed, 01 Sep 2010 20:51:56 +0200
Message-ID: <4C7EA0CC.2030609@grandegger.com>
References: <4C61EDE5.4030505@dsn.okisemi.com>	<4C62981B.8050402@grandegger.com>	<D5AB6E638E5A3E4B8F4406B113A5A19A28EA26CC@shsmsx501.ccr.corp.intel.com>	<4C63B6C9.5050804@grandegger.com>	<D5AB6E638E5A3E4B8F4406B113A5A19A28EA29DF@shsmsx501.ccr.corp.intel.com>
	<000501cb49a9$9cd4bf00$66f8800a@maildom.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Chih Howe <andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Qi <qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	ML netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, gregkh-l3A5Bk7waGM@public.gmane.org, "Wang,
	Yong Y" <yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	ML linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, arjan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Christian Pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>,
	Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
To: Masayuki Ohtake <masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <000501cb49a9$9cd4bf00$66f8800a-a06+6cuVnkTSQfdrb5gaxUEOCMrvLtNR@public.gmane.org>
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

Hello,

On 09/01/2010 09:45 AM, Masayuki Ohtake wrote:
> Sorry, for late response.
> ----- Original Message ----- 
> From: "Wang, Qi" <qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> To: "Masayuki Ohtak" <masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
> Cc: "Khor, Andrew Chih Howe" <andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>; <gregkh-l3A5Bk7waGM@public.gmane.org>; <arjan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>; "Wang, Yong
> Y" <yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>; "Wolfgang Grandegger" <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
> Sent: Thursday, August 12, 2010 6:00 PM
> Subject: RE: [MeeGo-Dev][PATCH] Topcliff: Update PCH_CAN driver to 2.6.35
...
>>>>> - The values for the hw-specific bit-timing registers should be derived
>>>>>   from the calculated values in "priv->can.bittiming":
>>>>>
>>>>>   http://lxr.linux.no/#linux+v2.6.35/include/linux/can/netlink.h#L17
>>>>>
> 
> I show current pch_can code below.
> 
> +static int pch_set_bittiming(struct net_device *ndev)
> +{
> + struct pch_can_priv *priv = netdev_priv(ndev);
> + struct pch_can_os *dev_can_os = priv->pch_can_os_p;
> + const struct can_bittiming *bt = &priv->can.bittiming;
> 
> Is the above TRUE, isn't it ?

The code fragment looks good. In that function you should then *derive*
the values of the bit-timing registers from the data fields of "bt". For
the SJA1000, you find the code here:

http://lxr.linux.no/#linux+v2.6.35/drivers/net/can/sja1000/sja1000.c#L202

>>>>> - The driver should handle state changes and communicate them to the
>>>>>   user space via error messages, if possible.
>>>>>
> What's "state chage" mean ?

Googling for "can bis states" returned:

http://www.softing.com/home/en/industrial-automation/products/can-bus/more-can-bus/error-handling/error-states.php?navanchor=3010510

The CAN controller usually triggers an interrupt when the state changes,
which allows the driver to track the CAN state and deliver that
information to the user space.

>>>>> - The driver should report errors to the user space via error messages.
>>>>>
> Is the above mean using alloc_can_err_skb and set error info and notify to kernel with netif_rx ?

Yes. Please search "Documentation/networking/can.txt" for "error frames"
for further information.

>>>>> - Bus errors seem not to be handled properly.I'm missing can_bus_off().
>>>>>   Does the controller recover from bus-off automatically?
> No.
> CAN driver recovers from Bus-off state.

You mean: "It does *not" recover automatically"! Right?

> 
>>>>>
>>>>> - I see that the driver uses many TX and RX objects. How do you avoid
>>>>>   out-of-order transmission and reception?
>>>> What do you mean out-of-order RX and TX?
>>>> Atom processor only supports in-order execution, and PCIe-based peripherals
>>> can solve it with consumer-producer model. Actually IC designer will take care
>>> of out-of-order PCIe CPLD transaction.
>>>
>>> I mean out-of-order transmission to or from the CAN bus. This is handled
>>> by the CAN controller hardware. It has nothing to to with the processor.
> Cannot avoid occurring rx or tx our-of-order.

It is a *requirement* as Oliver already pointed out. It's easy to
achieve if just one TX object is used but it might be tricky with more
than one.

Wolfgang.
