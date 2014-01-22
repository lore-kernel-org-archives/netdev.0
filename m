From: Ben Dooks <ben.dooks@codethink.co.uk>
Subject: Re: [PATCH v5] can: add Renesas R-Car CAN driver
Date: Wed, 22 Jan 2014 11:52:33 +0000
Message-ID: <52DFB101.8040907@codethink.co.uk>
References: <52DD0CC1.70205@pengutronix.de>	<CAMuHMdV5sMUnXb1Z1HeRk9+_dCGWrbD-DS62S7T4Be-77HvsvA@mail.gmail.com>	<52DD0F72.1000005@pengutronix.de> <20140120.111614.394228612374217980.davem@davemloft.net> <52DD9F3C.7000408@cogentembedded.com> <52DD927B.2060500@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	David Miller <davem@davemloft.net>, geert@linux-m68k.org,
	netdev@vger.kernel.org, wg@grandegger.com,
	linux-can@vger.kernel.org, linux-sh@vger.kernel.org,
	vksavl@gmail.com
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <52DD927B.2060500@pengutronix.de>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 20/01/14 21:17, Marc Kleine-Budde wrote:
> On 01/20/2014 11:12 PM, Sergei Shtylyov wrote:
> [...]
>
>>> I truly think using packed here is rediculous, please remove it unless
>>> you can prove that things won't work without it.
>>
>>     They will. But how about the following 'struct rcar_can_regs'?
>
> The strcuts in question are:
>
>> +/* Mailbox registers structure */
>> +struct rcar_can_mbox_regs {
>> +	u32 id;		/* IDE and RTR bits, SID and EID */
>> +	u8 stub;	/* Not used */
>> +	u8 dlc;		/* Data Length Code - bits [0..3] */
>> +	u8 data[8];	/* Data Bytes */
>> +	u8 tsh;		/* Time Stamp Higher Byte */
>> +	u8 tsl;		/* Time Stamp Lower Byte */
>> +} __packed;
>> +
>> +struct rcar_can_regs {
>> +	struct rcar_can_mbox_regs mb[RCAR_CAN_N_MBX]; /* Mailbox registers */
>> +	u32 mkr_2_9[8];	/* Mask Registers 2-9 */
>> +	u32 fidcr[2];	/* FIFO Received ID Compare Register */
>> +	u32 mkivlr1;	/* Mask Invalid Register 1 */
>> +	u32 mier1;	/* Mailbox Interrupt Enable Register 1 */
>> +	u32 mkr_0_1[2];	/* Mask Registers 0-1 */
>> +	u32 mkivlr0;    /* Mask Invalid Register 0*/
>> +	u32 mier0;      /* Mailbox Interrupt Enable Register 0 */
>> +	u8 pad_440[0x3c0];
>> +	u8 mctl[64];	/* Message Control Registers */
>> +	u16 ctlr;	/* Control Register */
>> +	u16 str;	/* Status register */
>> +	u8 bcr[3];	/* Bit Configuration Register */
>> +	u8 clkr;	/* Clock Select Register */
>> +	u8 rfcr;	/* Receive FIFO Control Register */
>> +	u8 rfpcr;	/* Receive FIFO Pointer Control Register */
>> +	u8 tfcr;	/* Transmit FIFO Control Register */
>> +	u8 tfpcr;       /* Transmit FIFO Pointer Control Register */
>> +	u8 eier;	/* Error Interrupt Enable Register */
>> +	u8 eifr;	/* Error Interrupt Factor Judge Register */
>> +	u8 recr;	/* Receive Error Count Register */
>> +	u8 tecr;        /* Transmit Error Count Register */
>> +	u8 ecsr;	/* Error Code Store Register */
>> +	u8 cssr;	/* Channel Search Support Register */
>> +	u8 mssr;	/* Mailbox Search Status Register */
>> +	u8 msmr;	/* Mailbox Search Mode Register */
>> +	u16 tsr;	/* Time Stamp Register */
>> +	u8 afsr;	/* Acceptance Filter Support Register */
>> +	u8 pad_857;
>> +	u8 tcr;		/* Test Control Register */
>> +	u8 pad_859[7];
>> +	u8 ier;		/* Interrupt Enable Register */
>> +	u8 isr;		/* Interrupt Status Register */
>> +	u8 pad_862;
>> +	u8 mbsmr;	/* Mailbox Search Mask Register */
>> +} __packed;
>
> I think they should work without packed, too.

I think this discussion proves why this is not a good idea.

IIRC, a compiler has the right to pad, or re-order structure
elements as it sees fit depending on the architecture and options.


-- 
Ben Dooks				http://www.codethink.co.uk/
Senior Engineer				Codethink - Providing Genius
