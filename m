From: Jean-Louis Dupond <info@dupondje.be>
Subject: Re: tg3 driver not advertising 1000mbit
Date: Fri, 26 Jun 2009 23:33:03 +0200
Message-ID: <4A453E8F.3000405@dupondje.be>
References: <7e14b58794647ea1b1b0a644e14a11f6@localhost> <1244831838.9225.71.camel@HP1> <4A32CDE9.7020602@dupondje.be> <1244844106.9225.92.camel@HP1> <4A32D3DB.30703@dupondje.be> <20090624173608.GA8985@xw6200.broadcom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Chan <mchan@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Christensen <davidch@broadcom.com>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from apollo.dupie.be ([85.17.239.130]:37199 "EHLO apollo.dupie.be"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754658AbZFZVdD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Jun 2009 17:33:03 -0400
In-Reply-To: <20090624173608.GA8985@xw6200.broadcom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

All tested kernels had the same issue (2.6.22, 2.5.25.4 & 2.6.28.1).

dmesg |grep tg3:

tg3.c:v3.97 (December 10, 2008)
tg3 0000:01:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
tg3 0000:01:00.0: setting latency timer to 64
tg3 0000:01:00.0: PME# disabled
tg3 0000:02:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
tg3 0000:02:00.0: setting latency timer to 64
tg3 0000:02:00.0: PME# disabled
tg3 0000:01:00.0: PME# disabled
tg3: eth0: Link is up at 1000 Mbps, full duplex.
tg3: eth0: Flow control is off for TX and off for RX.

Now here it booted @ Gbit speeds!

Matt Carlson schreef:
> Was there a version of the kernel where this device worked reliably?
> 
> Can you post the driver sign-on messages?  (I'm looking to see if ASF
> is enabled.)
> 
> On Fri, Jun 12, 2009 at 03:16:59PM -0700, Jean-Louis Dupond wrote:
>> I surely tried other cables. But its surely not the cable because:
>> 1) We tried other cables
>> 2) After a reboot it works, or after a mii-tool -R
>> 3) We have this issue on like +100 servers :(
>>
>> The servers are connected on a Dell PowerConnect 6248 switch.
>>
>> Sincerely
>>
>> Michael Chan schreef:
>>> On Fri, 2009-06-12 at 14:51 -0700, Jean-Louis Dupond wrote:
>>>> Hello!
>>>>
>>>> Here is a mii-tool -vvv on a box that doesn't advertise gbit speeds! It 
>>>> just doesn't advertise gbit @ random, sometimes it does, sometimes not! 
>>>> Without any logic in it!
>>>>
>>>> # mii-tool  -vvv
>>>> Using SIOCGMIIPHY=0x8947
>>>> eth0: link ok
>>>>     registers for MII PHY 1:
>>>>       1000 794d 0143 bed0 05e1 0000 0064 2001
>>>>       0000 0300 0000 0000 0000 0000 0000 3000
>>> Register 1 shows that autoneg did not complete (bit 5 is not set).
>>> The tg3 device has advertised 10/100/1000 in register 4 and register 9,
>>> but registers 5 and 0xa (link partner's advertisement registers are 0).
>>>
>>> When it works, these registers should look very different.
>>>
>>> Have you tried other cables?  What is the link partner?
>>>
>>>>       0000 0101 0000 0000 0000 0000 0000 0000
>>>>       7477 0104 0000 ffff 2801 0000 8000 0000
>>>>     product info: vendor 00:50:ef, model 45 rev 0
>>>>     basic mode:   autonegotiation enabled
>>>>     basic status: link ok
>>>>     capabilities: 1000baseT-HD 1000baseT-FD 100baseTx-FD 100baseTx-HD
>>>> 10baseT-FD 10baseT-HD
>>>>     advertising:  100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD flow-
>>>> control
>>>>
>>>> # dmesg | grep tg3
>>>> [    3.331702] tg3.c:v3.92.1 (June 9, 2008)
>>>> [   18.238654] tg3: eth0: Link is up at 10 Mbps, half duplex.
>>>> [   18.238654] tg3: eth0: Flow control is off for TX and off for RX.
>>>>
>>>>
>>>
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
