From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v2] can: Topcliff: PCH_CAN driver: Fix build
	warnings
Date: Wed, 03 Nov 2010 17:15:42 +0100
Message-ID: <4CD18AAE.9040300@grandegger.com>
References: <4CCAA3D4.8070408@dsn.okisemi.com>	<4CCAC4CD.7000503@pengutronix.de>
	<4CCAF517.2000409@pengutronix.de>	<4CCB213A.2020206@grandegger.com>
	<4CCE9F0B.1000901@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, margie.foster-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, Masayuki Ohtake <masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>,
	kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, Christian Pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4CCE9F0B.1000901-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
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

On 11/01/2010 12:05 PM, Marc Kleine-Budde wrote:
> Hello,
> =

> On 10/29/2010 09:32 PM, Wolfgang Grandegger wrote:
> =

> some comments inline.
> =

> [...]
...
>>>> +	if (status & PCH_LEC_ALL) {
>>>> +		priv->can.can_stats.bus_error++;
>>>> +		stats->rx_errors++;
>>>> +		switch (status & PCH_LEC_ALL) {
>>>
>>> I suggest to convert to a if-bit-set because there might be more than
>>> one bit set.
>>
>> Marc, what do you mean here. It's an enumeraton. Maybe the following
>> code is more clear:
> =

> Oh, I haven't looked this one up in the datasheet.
>>
>> 	lec =3D status & PCH_LEC_ALL;
>> 	if (lec > 0) {
> =

> or "if (lec)", YMMV
> =

>> 		switch (lec) {
>>
>>>> +		case PCH_STUF_ERR:
>>>> +			cf->data[2] |=3D CAN_ERR_PROT_STUFF;
>>>> +			break;
>>>> +		case PCH_FORM_ERR:
>>>> +			cf->data[2] |=3D CAN_ERR_PROT_FORM;
>>>> +			break;
>>>> +		case PCH_ACK_ERR:
>>>> +			cf->data[2] |=3D CAN_ERR_PROT_LOC_ACK |
>>>> +				       CAN_ERR_PROT_LOC_ACK_DEL;
>>
>> Could you check what that type of bus error that is? Usually it's a ack
>> lost error.
>>
>>>> +			break;
>>>> +		case PCH_BIT1_ERR:
>>>> +		case PCH_BIT0_ERR:
>>>> +			cf->data[2] |=3D CAN_ERR_PROT_BIT;
>>>> +			break;
>>>> +		case PCH_CRC_ERR:
>>>> +			cf->data[2] |=3D CAN_ERR_PROT_LOC_CRC_SEQ |
>>>> +				       CAN_ERR_PROT_LOC_CRC_DEL;
>>>> +			break;
>>>> +		default:
>>>> +			iowrite32(status | PCH_LEC_ALL, &priv->regs->stat);
>>>> +			break;
>>>> +		}
>>>> +
>>>> +	}

At a closer look, I doubt that the above LEC handling is correct.
According to the manual: "when the LEC shows the value =937,=94 this value
was written to the LEC by the CPU; thus, no CAN bus event was detected"
Therefore the LEC bits should be properly *initialized* and *reset* to
0x7, which I do not find in the code.

Wolfgang.
