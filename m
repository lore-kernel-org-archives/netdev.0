From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v4 1/1] can: c_can: Added support for Bosch
	C_CAN controller
Date: Wed, 12 Jan 2011 09:41:21 +0100
Message-ID: <4D2D6931.7020409@grandegger.com>
References: <1294746592-12144-1-git-send-email-bhupesh.sharma@st.com>	<4D2C5845.4050805@grandegger.com>	<D5ECB3C7A6F99444980976A8C6D896384DEAFA3066@EAPEX1MAIL1.st.com>	<4D2D6830.9090701@grandegger.com>
	<D5ECB3C7A6F99444980976A8C6D896384DEAFA31AD@EAPEX1MAIL1.st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org" <Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Bhupesh SHARMA <bhupesh.sharma-qxv4g6HH51o@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <D5ECB3C7A6F99444980976A8C6D896384DEAFA31AD-8vAmw3ZAcdzhJTuQ9jeba9BPR1lH4CV8@public.gmane.org>
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

On 01/12/2011 09:38 AM, Bhupesh SHARMA wrote:
> Hi Wolfgang,
> 
>> On 01/12/2011 04:30 AM, Bhupesh SHARMA wrote:
>>> Hi Wolfgang,
>>>
>>>> -----Original Message-----
>>>> From: Wolfgang Grandegger [mailto:wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org]
>>>> Hi Bhupesh,
>>>>
>>>> some final nitpicking as you need to fix Marc remarks anyway...
>>>>
>>>> On 01/11/2011 12:49 PM, Bhupesh Sharma wrote:
>>>>> Bosch C_CAN controller is a full-CAN implementation which is
>>>> compliant
>>>>> to CAN protocol version 2.0 part A and B. Bosch C_CAN user manual
>> can
>>>> be
>>>>> obtained from:
>>>>> http://www.semiconductors.bosch.de/media/en/pdf/ipmodules_1/
>>>>> c_can/users_manual_c_can.pdf
>>>>>
>>>>> This patch adds the support for this controller.
>>>>> The following are the design choices made while writing the
>>>> controller
>>>>> driver:
>>>>> 1. Interface Register set IF1 has be used only in the current
>> design.
>>>>> 2. Out of the 32 Message objects available, 16 are kept aside for
>> RX
>>>>>    purposes and the rest for TX purposes.
>>>>> 3. NAPI implementation is such that both the TX and RX paths
>> function
>>>>>    in polling mode.
>>>>>
>>>>> Changes since V3:
>>>>> 1. Corrected commenting style.
>>>>> 2. Removing *non-required* header files from driver files.
>>>>> 3. Removed extra *non-required* outer brackets globally.
>>>>> 4. Implemented and used a inline routine to check BUSY status.
>>>>> 5. Added a board-specific param *priv* inside the c_can_priv
>> struct.
>>>>>
>>>>> Signed-off-by: Bhupesh Sharma <bhupesh.sharma-qxv4g6HH51o@public.gmane.org>
>>>>
>>>> ...
>>>>> +++ b/drivers/net/can/c_can/c_can.h
>>>>> @@ -0,0 +1,235 @@
>>>>> +/*
>>>>> + * CAN bus driver for Bosch C_CAN controller
>>>>> + *
>>>>> + * Copyright (C) 2010 ST Microelectronics
>>>>> + * Bhupesh Sharma <bhupesh.sharma-qxv4g6HH51o@public.gmane.org>
>>>>> + *
>>>>> + * Borrowed heavily from the C_CAN driver originally written by:
>>>>> + * Copyright (C) 2007
>>>>> + * - Sascha Hauer, Marc Kleine-Budde, Pengutronix
>>>> <s.hauer-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
>>>>> + * - Simon Kallweit, intefo AG <simon.kallweit-+G9qxTFKJT/tRgLqZ5aouw@public.gmane.org>
>>>>> + *
>>>>> + * TX and RX NAPI implementation has been borrowed from at91 CAN
>>>> driver
>>>>> + * written by:
>>>>> + * Copyright
>>>>> + * (C) 2007 by Hans J. Koch <hjk-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
>>>>> + * (C) 2008, 2009 by Marc Kleine-Budde <kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
>>>>> + *
>>>>> + * Bosch C_CAN controller is compliant to CAN protocol version 2.0
>>>> part A and B.
>>>>> + * Bosch C_CAN user manual can be obtained from:
>>>>> + *
>>>> http://www.semiconductors.bosch.de/media/en/pdf/ipmodules_1/c_can/
>>>>> + * users_manual_c_can.pdf
>>>>> + *
>>>>> + * This file is licensed under the terms of the GNU General Public
>>>>> + * License version 2. This program is licensed "as is" without any
>>>>> + * warranty of any kind, whether express or implied.
>>>>> + */
>>>>> +
>>>>> +#ifndef C_CAN_H
>>>>> +#define C_CAN_H
>>>>> +
>>>>> +/* control register */
>>>>> +#define CONTROL_TEST		BIT(7)
>>>>> +#define CONTROL_CCE		BIT(6)
>>>>> +#define CONTROL_DISABLE_AR	BIT(5)
>>>>> +#define CONTROL_ENABLE_AR	(0 << 5)
>>>>> +#define CONTROL_EIE		BIT(3)
>>>>> +#define CONTROL_SIE		BIT(2)
>>>>> +#define CONTROL_IE		BIT(1)
>>>>> +#define CONTROL_INIT		BIT(0)
>>>>> +
>>>>> +/* test register */
>>>>> +#define TEST_RX			BIT(7)
>>>>> +#define TEST_TX1		BIT(6)
>>>>> +#define TEST_TX2		BIT(5)
>>>>> +#define TEST_LBACK		BIT(4)
>>>>> +#define TEST_SILENT		BIT(3)
>>>>> +#define TEST_BASIC		BIT(2)
>>>>> +
>>>>> +/* status register */
>>>>> +#define STATUS_BOFF		BIT(7)
>>>>> +#define STATUS_EWARN		BIT(6)
>>>>> +#define STATUS_EPASS		BIT(5)
>>>>> +#define STATUS_RXOK		BIT(4)
>>>>> +#define STATUS_TXOK		BIT(3)
>>>>> +#define STATUS_LEC_MASK		0x07
>>>>> +
>>>>> +/* error counter register */
>>>>> +#define ERR_COUNTER_TEC_MASK	0xff
>>>>> +#define ERR_COUNTER_TEC_SHIFT	0
>>>>> +#define ERR_COUNTER_REC_SHIFT	8
>>>>> +#define ERR_COUNTER_REC_MASK	(0x7f << ERR_COUNTER_REC_SHIFT)
>>>>> +#define ERR_COUNTER_RP_SHIFT	15
>>>>> +#define ERR_COUNTER_RP_MASK	(0x1 << ERR_COUNTER_RP_SHIFT)
>>>>
>>>> s/ERR_COUNTER/ERR_CNT/ to match the member name.
>>>
>>> Ok.
>>>
>>>>> +
>>>>> +/* bit-timing register */
>>>>> +#define BTR_BRP_MASK		0x3f
>>>>> +#define BTR_BRP_SHIFT		0
>>>>> +#define BTR_SJW_SHIFT		6
>>>>> +#define BTR_SJW_MASK		(0x3 << BTR_SJW_SHIFT)
>>>>> +#define BTR_TSEG1_SHIFT		8
>>>>> +#define BTR_TSEG1_MASK		(0xf << BTR_TSEG1_SHIFT)
>>>>> +#define BTR_TSEG2_SHIFT		12
>>>>> +#define BTR_TSEG2_MASK		(0x7 << BTR_TSEG2_SHIFT)
>>>>> +
>>>>> +/* brp extension register */
>>>>> +#define BRP_EXT_BRPE_MASK	0x0f
>>>>> +#define BRP_EXT_BRPE_SHIFT	0
>>>>> +
>>>>> +/* IFx command request */
>>>>> +#define IF_COMR_BUSY		BIT(15)
>>>>> +
>>>>> +/* IFx command mask */
>>>>> +#define IF_COMM_WR		BIT(7)
>>>>> +#define IF_COMM_MASK		BIT(6)
>>>>> +#define IF_COMM_ARB		BIT(5)
>>>>> +#define IF_COMM_CONTROL		BIT(4)
>>>>> +#define IF_COMM_CLR_INT_PND	BIT(3)
>>>>> +#define IF_COMM_TXRQST		BIT(2)
>>>>> +#define IF_COMM_DATAA		BIT(1)
>>>>> +#define IF_COMM_DATAB		BIT(0)
>>>>> +#define IF_COMM_ALL		(IF_COMM_MASK | IF_COMM_ARB | \
>>>>> +				IF_COMM_CONTROL | IF_COMM_TXRQST | \
>>>>> +				IF_COMM_DATAA | IF_COMM_DATAB)
>>>>> +
>>>>> +/* IFx arbitration */
>>>>> +#define IF_ARB_MSGVAL		BIT(15)
>>>>> +#define IF_ARB_MSGXTD		BIT(14)
>>>>> +#define IF_ARB_TRANSMIT		BIT(13)
>>>>> +
>>>>> +/* IFx message control */
>>>>> +#define IF_MCONT_NEWDAT		BIT(15)
>>>>> +#define IF_MCONT_MSGLST		BIT(14)
>>>>> +#define IF_MCONT_CLR_MSGLST	(0 << 14)
>>>>> +#define IF_MCONT_INTPND		BIT(13)
>>>>> +#define IF_MCONT_UMASK		BIT(12)
>>>>> +#define IF_MCONT_TXIE		BIT(11)
>>>>> +#define IF_MCONT_RXIE		BIT(10)
>>>>> +#define IF_MCONT_RMTEN		BIT(9)
>>>>> +#define IF_MCONT_TXRQST		BIT(8)
>>>>> +#define IF_MCONT_EOB		BIT(7)
>>>>> +#define IF_MCONT_DLC_MASK	0xf
>>>>> +
>>>>> +/*
>>>>> + * IFx register masks:
>>>>> + * allow easy operation on 16-bit registers when the
>>>>> + * argument is 32-bit instead
>>>>> + */
>>>>> +#define IFX_WRITE_LOW_16BIT(x)	((x) & 0xFFFF)
>>>>> +#define IFX_WRITE_HIGH_16BIT(x)	(((x) & 0xFFFF0000) >> 16)
>>>>> +
>>>>> +/* message object split */
>>>>> +#define C_CAN_NO_OF_OBJECTS	31
>>>>> +#define C_CAN_MSG_OBJ_RX_NUM	16
>>>>> +#define C_CAN_MSG_OBJ_TX_NUM	16
>>>>> +
>>>>> +#define C_CAN_MSG_OBJ_RX_FIRST	0
>>>>> +#define C_CAN_MSG_OBJ_RX_LAST	(C_CAN_MSG_OBJ_RX_FIRST + \
>>>>> +				C_CAN_MSG_OBJ_RX_NUM - 1)
>>>>> +
>>>>> +#define C_CAN_MSG_OBJ_TX_FIRST	(C_CAN_MSG_OBJ_RX_LAST + 1)
>>>>> +#define C_CAN_MSG_OBJ_TX_LAST	(C_CAN_MSG_OBJ_TX_FIRST + \
>>>>> +				C_CAN_MSG_OBJ_TX_NUM - 1)
>>>>> +
>>>>> +#define C_CAN_MSG_OBJ_RX_SPLIT	8
>>>>> +#define C_CAN_MSG_RX_LOW_LAST	(C_CAN_MSG_OBJ_RX_SPLIT - 1)
>>>>> +
>>>>> +#define C_CAN_NEXT_MSG_OBJ_MASK	(C_CAN_MSG_OBJ_TX_NUM - 1)
>>>>> +#define RECEIVE_OBJECT_BITS	0x0000ffff
>>>>> +
>>>>> +/* status interrupt */
>>>>> +#define STATUS_INTERRUPT	0x8000
>>>>> +
>>>>> +/* global interrupt masks */
>>>>> +#define ENABLE_ALL_INTERRUPTS	1
>>>>> +#define DISABLE_ALL_INTERRUPTS	0
>>>>> +
>>>>> +/* minimum timeout for checking BUSY status */
>>>>> +#define MIN_TIMEOUT_VALUE	6
>>>>> +
>>>>> +/* napi related */
>>>>> +#define C_CAN_NAPI_WEIGHT	C_CAN_MSG_OBJ_RX_NUM
>>>>> +
>>>>> +/* c_can IF registers */
>>>>> +struct c_can_if_regs {
>>>>> +	u16 com_reg;
>>>>> +	u16 com_mask;
>>>>> +	u16 mask1;
>>>>> +	u16 mask2;
>>>>> +	u16 arb1;
>>>>> +	u16 arb2;
>>>>> +	u16 msg_cntrl;
>>>>> +	u16 data[4];
>>>>> +	u16 _reserved[13];
>>>>> +};
>>>>> +
>>>>> +/* c_can hardware registers */
>>>>> +struct c_can_regs {
>>>>> +	u16 control;
>>>>> +	u16 status;
>>>>> +	u16 err_cnt;
>>>>> +	u16 btr;
>>>>> +	u16 interrupt;
>>>>> +	u16 test;
>>>>> +	u16 brp_ext;
>>>>> +	u16 _reserved1;
>>>>> +	struct c_can_if_regs intf[2]; /* [0] = IF1 and [1] = IF2 */
>>>>
>>>> I not happy with the name "intf". Sounds more like an interrupt
>> related
>>>> property. Above you already use the prefix IF_ for the corresponding
>>>> macro definitions and somewhere else the name "iface".
>>>
>>> I tried using the name *if* suggested by you here but the compiler
>> will complain
>>> considering it as a usage of if-construct. Do you have a better name
>> that we
>>> can use here?
>>
>> Oh, I was not aware ot that. Sorry for the noise! Then your old
>> "ifregs"
>> or "iface" would be fine, I think. I just see that the pch_can uses
>> "ifregs" as well.
>>
> 
> Yes, I get checked the pch_can driver as well. It also uses the name *ifregs*.
> Let's keep the name *ifregs* then.

D'accord.

Wolfgang.
