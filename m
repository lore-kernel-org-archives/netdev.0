From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH v2] can: add Renesas R-Car CAN driver
Date: Sun, 03 Nov 2013 20:38:38 +0100
Message-ID: <5276A63E.3070505@grandegger.com>
References: <201310250303.00695.sergei.shtylyov@cogentembedded.com> <526AC65B.5020203@grandegger.com> <52742A0F.7040707@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-sh@vger.kernel.org, vksavl@gmail.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org, mkl@pengutronix.de,
	linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <52742A0F.7040707@cogentembedded.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/01/2013 11:24 PM, Sergei Shtylyov wrote:
> On 10/25/2013 11:28 PM, Wolfgang Grandegger wrote:
> 
>>> Add support for the CAN controller found in Renesas R-Car SoCs.
> 
>>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> 
> [...]
> 
>>> Index: linux-can-next/drivers/net/can/rcar_can.c
>>> ===================================================================
>>> --- /dev/null
>>> +++ linux-can-next/drivers/net/can/rcar_can.c
>>> @@ -0,0 +1,920 @@
> [...]
>>> +static bool autorecovery;
>>> +module_param(autorecovery, bool, 0644);
>>> +MODULE_PARM_DESC(autorecovery, "Automatic hardware recovery from
>>> bus-off");
> 
>> Software recovery is the preferred solution. No need to support
>> automatic recovery by the hardware.
> 
>    OK, removed it.
> 
>>> +/* Mailbox registers structure */
>>> +struct rcar_can_mbox_regs {
>>> +    u32 id;        /* IDE and RTR bits, SID and EID */
>>> +    u8 stub;    /* Not used */
>>> +    u8 dlc;        /* Data Length Code - bits [0..3] */
>>> +    u8 data[8];    /* Data Bytes */
>>> +    u8 tsh;        /* Time Stamp Higher Byte */
>>> +    u8 tsl;        /* Time Stamp Lower Byte */
> 
>> I would add padding bytes here to ensure alignment.
> 
>    What padding? This is how the hardware registers are laid out. I
> think I should rather add __packed after }.

OK, I was confused that data does not start on a 4 byte boundary.


>>> +            rcar_can_writeb(priv, RCAR_CAN_ECSR, (u8)~ECSR_ADEF);
> 
>> Please avoid casts here and below.
> 
>    These casts help avoid compiler warnings.

Well instead of using casts the declaration of ECSR_ADEF and otheres
should be fixed. I think the problem is that BIT is declared as shown below:

 #define BIT(nr)                 (1UL << (nr))

Using BIT seems not appropriate here.

Wolfgang,

