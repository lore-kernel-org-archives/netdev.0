From: Murali Karicheri <m-karicheri2@ti.com>
Subject: Re: [PATCH net-next v8 0/4] net: Add Keystone NetCP ethernet driver
 support
Date: Wed, 28 Jan 2015 15:43:57 -0500
Message-ID: <54C94A0D.9050505@ti.com>
References: <1421367007-19744-1-git-send-email-m-karicheri2@ti.com> <20150119.151106.822126941934010309.davem@davemloft.net> <54BE7A00.2020205@ti.com> <25883654.BLFxICW9P0@wuerfel> <54C91328.6030208@ti.com> <54C91FDD.1000009@ti.com> <54C92878.3030207@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, <devicetree@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54C92878.3030207@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/28/2015 01:20 PM, Murali Karicheri wrote:
> On 01/28/2015 12:43 PM, Murali Karicheri wrote:
>> On 01/28/2015 11:49 AM, Murali Karicheri wrote:
>>> On 01/27/2015 05:28 PM, Arnd Bergmann wrote:
>>>> On Tuesday 20 January 2015 10:53:36 Murali Karicheri wrote:
>>>>> On 01/19/2015 03:11 PM, David Miller wrote:
>>>>>> From: Murali Karicheri<m-karicheri2@ti.com>
>>>>>> Date: Thu, 15 Jan 2015 19:10:03 -0500
>>>>>>
>>>>>>> The Network Coprocessor (NetCP) is a hardware accelerator that
>>>>>>> processes
>>>>>>> Ethernet packets. NetCP has a gigabit Ethernet (GbE) subsystem =
with
>>>>>>> a ethernet
>>>>>>> switch sub-module to send and receive packets. NetCP also inclu=
des
>>>>>>> a packet
>>>>>>> accelerator (PA) module to perform packet classification operat=
ions
>>>>>>> such as
>>>>>>> header matching, and packet modification operations such as che=
cksum
>>>>>>> generation. NetCP can also optionally include a Security
>>>>>>> Accelerator(SA)
>>>>>>> capable of performing IPSec operations on ingress/egress packet=
s.
>>>>>>>
>>>>>>> Keystone SoC's also have a 10 Gigabit Ethernet Subsystem (XGbE)
>>>>>>> which
>>>>>>> includes a 3-port Ethernet switch sub-module capable of 10Gb/s =
and
>>>>>>> 1Gb/s rates per Ethernet port.
>>>>>>>
>>>>>>> Both GBE and XGBE network processors supported using common
>>>>>>> driver. It
>>>>>>> is also designed to handle future variants of NetCP.
>>>>>>
>>>>>> Series applied to net-next, thanks.
>>>>> David,
>>>>>
>>>>> Thanks a lot for applying this series. This helps us move forward=
 to
>>>>> work on the next set of patches.
>>>>
>>>> Hi Murali,
>>>>
>>>> Building an ARM 'allmodconfig' kernel now runs into two separate
>>>> problems
>>>> from your driver:
>>>>
>>>> - you have two module_init() instances in one module, which confli=
ct.
>>>>
>>>> - you have two files that are linked into more than one module, so
>>>> building
>>>> both TI_CPSW and TI_KEYSTONE_NETCP in the same kernel fails.
>>>>
>>>> The answer to both of these is probably to have separate loadable
>>>> modules,
>>>> but you might be able to come up with a different solution.
>>> Arnd,
>>>
>>> Thanks for letting us know. We will look into this.
>>>
>>> How do I reproduce this? Is there a defconfig used for allmodconfig=
? I
>>> am unable to find one. Any details to reproduce this will be useful=
=2E
>>>
>> Ok I think I found it.
>>
>> I did this with next-next branch and it seems to work. I will make
>> kernel build to reproduce this.
>>
>> make ARCH=3Darm allmodconfig
>> make uImage;
>>
>> I am building it now.
> Arnd,
>
> I see allmodconfig configure NetCP driver as module. My uImage build
> from net-next branch went through fine. I am building modules right n=
ow
> and should show error as you have pointed out. Let me know if you any
> issues on how I am working to reproduce the issue (wrong branch, wron=
g
> /incomplete commands etc. I have my CROSS_COMPILE and ARCH set in my
> env). Want to reproduce this so as to make sure my fix is addressing
> this. Hope I am on the right track.

Reproduced this. Following errors seen when building the modules.

   LD [M]  drivers/net/ethernet/ti/keystone_netcp.o
drivers/net/ethernet/ti/netcp_ethss.o: In function `init_module':
netcp_ethss.c:(.init.text+0x0): multiple definition of `init_module'
drivers/net/ethernet/ti/netcp_core.o:netcp_core.c:(.init.text+0x0):=20
first defined here
drivers/net/ethernet/ti/netcp_ethss.o: In function `cleanup_module':
netcp_ethss.c:(.exit.text+0x0): multiple definition of `cleanup_module'
drivers/net/ethernet/ti/netcp_core.o:netcp_core.c:(.exit.text+0x0):=20
first defined here
make[4]: *** [drivers/net/ethernet/ti/keystone_netcp.o] Error 1


BTW, I had to disable cpsw_ale.c to get to build keystone NetCP. I am=20
assuming someone from TI is addressing this.

drivers/net/ethernet/ti/cpsw_ale.c: In function =91cpsw_ale_start=92:
drivers/net/ethernet/ti/cpsw_ale.c:759:2: error: =91KBUILD_MODNAME=92=20
undeclared (first use in this function)
drivers/net/ethernet/ti/cpsw_ale.c:759:2: note: each undeclared=20
identifier is reported only once for each function it appears in

Murali

>
> Thanks
>
> Murali
>>
>> Murali
>>> Thanks.
>>>
>>> Murali
>>>>
>>>> Arnd
>>>
>>>
>>
>>
>
>


--=20
Murali Karicheri
Linux Kernel, Texas Instruments
