From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v5] can: add Renesas R-Car CAN driver
Date: Fri, 28 Feb 2014 15:16:23 +0400
Message-ID: <53107007.7050802@cogentembedded.com>
References: <201312270037.15822.sergei.shtylyov@cogentembedded.com> <52DCE9E4.7010209@pengutronix.de> <52E3148E.2010608@cogentembedded.com> <52FCB6C5.6020001@pengutronix.de> <53069445.80408@cogentembedded.com> <5310521E.6000708@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-sh@vger.kernel.org, vksavl@gmail.com
To: Marc Kleine-Budde <mkl@pengutronix.de>, netdev@vger.kernel.org,
	wg@grandegger.com, linux-can@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <5310521E.6000708@pengutronix.de>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 28-02-2014 13:08, Marc Kleine-Budde wrote:

>>>> 1. According to documentation BCR is the 24-bit register.
>>>> Actually we can consider some 32-bit register that combines BCR and
>>>> CLKR but according to documentation there are two separate registers.
>>>> 2. BCR has 8- ,16-, and 32-bit access (according to documentation).
>>>> 3. This is the algorithm that the documentation suggests.
>>>> 4. We had a driver version with byte access but 32-bit access seems
>>>> shorter.

>>> Please use a normal read-modify-write 32 bit access.

>>     IMO, reading 32-bits is futile, as we're going to completely
>> overwrite those 24 bits that constitute BCR. So I kept the 8-bit CLKR
>> read but removed the CLKR write in the end. I've also added a comment
>> clarifying why CLKR is positioned in the LSBs of 32-bit word (while it's
>> address would assume MSBs).
>> The host bus is big-endian but byte-swaps at least 16- and 32-bit
>> accesses, so that read[wl]()/write[wl]() work. 8-bit accesses are not
>> byte swapped, despite what the figure in the manual shows.

> A 32 bit read/modify/write is a standard operation, nothing special, no
> need to worry about byte swapping or anything like this.

    Oh, really? 8-)
    Don't you know that read[bwlq]() assume little-endian memory layout and to 
read from big-endian 32-bit register one normally needs readl_be()?

> Marc

WBR, Sergei

