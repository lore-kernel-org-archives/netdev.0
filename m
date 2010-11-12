From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v2] can: Topcliff: PCH_CAN driver: Fix build
	warnings
Date: Fri, 12 Nov 2010 12:45:42 +0100
Message-ID: <4CDD28E6.9060006@grandegger.com>
References: <4CCAA3D4.8070408@dsn.okisemi.com>	<4CCAC4CD.7000503@pengutronix.de>
	<4CCAF517.2000409@pengutronix.de>	<4CCB213A.2020206@grandegger.com>
	<004a01cb825a$3a8bd060$66f8800a@maildom.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, margie.foster-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, Masayuki Ohtake <masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>,
	Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	Christian Pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>, kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: Tomoya MORINAGA <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <004a01cb825a$3a8bd060$66f8800a-a06+6cuVnkTSQfdrb5gaxUEOCMrvLtNR@public.gmane.org>
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

On 11/12/2010 12:10 PM, Tomoya MORINAGA wrote:
> On Saturday, October 30, 2010 4:32 AM, Wolfgang Grandegger wrote :
> 
> Sorry, for my late.
> 
>>>> +
>>>> +#define PCH_RX_OK 0x00000010
>>>> +#define PCH_TX_OK 0x00000008
>>>> +#define PCH_BUS_OFF 0x00000080
>>>> +#define PCH_EWARN 0x00000040
>>>> +#define PCH_EPASSIV 0x00000020
>>>> +#define PCH_LEC0 0x00000001
>>>> +#define PCH_LEC1 0x00000002
>>>> +#define PCH_LEC2 0x00000004
>>>
>>> These are just single set bit, please use BIT()
>>> Consider adding the name of the corresponding register to the define's
>>> name.
> 
> I agree.
> 
>>>
>>>> +#define PCH_LEC_ALL (PCH_LEC0 | PCH_LEC1 | PCH_LEC2)
>>>> +#define PCH_STUF_ERR PCH_LEC0
>>>> +#define PCH_FORM_ERR PCH_LEC1
>>>> +#define PCH_ACK_ERR (PCH_LEC0 | PCH_LEC1)
>>>> +#define PCH_BIT1_ERR PCH_LEC2
>>>> +#define PCH_BIT0_ERR (PCH_LEC0 | PCH_LEC2)
>>>> +#define PCH_CRC_ERR (PCH_LEC1 | PCH_LEC2)
>>
>> This is an enumeration:
>>
>> enum {
>> PCH_STUF_ERR = 1,
>> PCH_FORM_ERR,
>> PCH_ACK_ERR,
>> PCH_BIT1_ERR;
>> PCH_BIT0_ERR,
>> PCH_CRC_ERR,
>> PCH_LEC_ALL;
>> }
> 
> No, 
> LEC is for bit assignment.
> Thus, "enum" can't be used.

Why? For me it's a classical enum because the value matters, and *not*
the individual bit. Do you agree?

>>> I suggest to convert to a if-bit-set because there might be more than
>>> one bit set.
>>
>> Marc, what do you mean here. It's an enumeraton. Maybe the following
>> code is more clear:
>>
>> lec = status & PCH_LEC_ALL;
>> if (lec > 0) {
>> switch (lec) {
> 
> No.
> LEC is not enum.

See also my sub-sequent comment here:

http://marc.info/?l=linux-netdev&m=128880088907148&w=2

>>>> + case PCH_STUF_ERR:
>>>> + cf->data[2] |= CAN_ERR_PROT_STUFF;
>>>> + break;
>>>> + case PCH_FORM_ERR:
>>>> + cf->data[2] |= CAN_ERR_PROT_FORM;
>>>> + break;
>>>> + case PCH_ACK_ERR:
>>>> + cf->data[2] |= CAN_ERR_PROT_LOC_ACK |
>>>> +        CAN_ERR_PROT_LOC_ACK_DEL;
>>
>> Could you check what that type of bus error that is? Usually it's a ack
>> lost error.
> 
> I will modify.
> BTW, I can see ti_hecc also has the above the same code.

Yes, also the AT91 driver uses a somehow incorrect error mask. I will
check and provide a patch a.s.a.p.

>>
>>>> + break;
>>>> + case PCH_BIT1_ERR:
>>>> + case PCH_BIT0_ERR:
>>>> + cf->data[2] |= CAN_ERR_PROT_BIT;
>>>> + break;
>>>> + case PCH_CRC_ERR:
>>>> + cf->data[2] |= CAN_ERR_PROT_LOC_CRC_SEQ |
>>>> +        CAN_ERR_PROT_LOC_CRC_DEL;
>>>> + break;
>>>> + default:
>>>> + iowrite32(status | PCH_LEC_ALL, &priv->regs->stat);
>>>> + break;
>>>> + }
>>>> +
>>>> + }
>>
>> Also, could you please add the TEC and REC:
>>
>> cf->data[6] = ioread32(&priv->regs->errc) & CAN_TEC;
>> cf->data[7] = (ioread32(&priv->regs->errc) & CAN_REC) >> 8;
> 
> I will add.

BTW: it could be done with one I/O call:

  errc = ioread32(&priv->regs->errc);
  cf->data[6] = errc & CAN_TEC;
  cf->data[7] = (errc & CAN_REC) >> 8;

> But I couldn't find 

Don't understand? It's also implemented for the SJA1000 driver:

http://lxr.linux.no/#linux+v2.6.36/drivers/net/can/sja1000/sja1000.c#L466

Wolfgang.
