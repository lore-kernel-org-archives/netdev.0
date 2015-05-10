From: Philippe Reynes <tremyfr@gmail.com>
Subject: Re: [PATCH] net: fec: add support of ethtool get_regs
Date: Sun, 10 May 2015 23:43:02 +0200
Message-ID: <554FD0E6.6050701@gmail.com>
References: <20150509211746.GY2067@n2100.arm.linux.org.uk> <CAOMZO5A2POPCYHzotc5SEhtmCuBrXiK7bdjF=UeiXZEqcnGMag@mail.gmail.com> <554E8735.302@gmail.com> <20150509.210128.2284066611245510581.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: festevam@gmail.com, linux@arm.linux.org.uk, B38611@freescale.com,
	Frank.Li@freescale.com, LW@karo-electronics.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150509.210128.2284066611245510581.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi david,

On 10/05/15 03:01, David Miller wrote:
> From: Philippe Reynes<tremyfr@gmail.com>
> Date: Sun, 10 May 2015 00:16:21 +0200
>
>> Hi Fabio,
>>
>> On 09/05/15 23:59, Fabio Estevam wrote:
>>> Philippe,
>>>
>>> On Sat, May 9, 2015 at 6:17 PM, Russell King - ARM Linux
>>> <linux@arm.linux.org.uk>   wrote:
>>>
>>>> Using memcpy_fromio() to copy device registers is not a good idea -
>>>> it can use a variable access size which can cause bus faults.
>>>
>>> An example on how memcpy_fromio() can be avoided in get_regs:
>>> drivers/net/ethernet/samsung/sxgbe/sxgbe_ethtool.c
>>
>> Thanks for pointing me this example. I've already send a patch,
>> and I've used drivers/net/ethernet/freescale/gianfar_ethtool.c
>> as example. I hope it's a good example too.
>
> I think you need to be much more careful and conservative in your
> implementation.
>
> You should skip I/O addresses that don't have defined registers
> at those offsets for the chip in question.

Ok, I've added an array with all register, so I only read defined registers.

> Also, you should _very_ carefully evaluate each and every register you
> dump and potentially skip certain registers which have strong negative
> side effects if read arbitrarily.
>
> For example, dumping the interrupt status register could cause pending
> interrupt status to be cleared, and thus cause the driver to lose
> interrupts and subsequently packet processing will hang.

Thanks for the feedback. I've read all the register, and all registers
can be read without negative side effect. Even interrupt status register,
interrupt are cleared when the register EIR is written (not read).

Regards,
Philippe
