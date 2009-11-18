From: Max Krasnyansky <maxk@qualcomm.com>
Subject: Re: [PATCH] Documentation, clarify tuntap IPX example.
Date: Tue, 17 Nov 2009 21:52:55 -0800
Message-ID: <4B038BB7.2050902@qualcomm.com>
References: <d45a3acc0911171730kc3a03d5iacec6d9ef4b1874c@mail.gmail.com>	 <4B035081.8040900@qualcomm.com> <d45a3acc0911171814i310bbd16t8ff3fba2410e9375@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: andrew hendry <andrew.hendry@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine01.qualcomm.com ([199.106.114.254]:30957 "EHLO
	wolverine01.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751369AbZKRFwu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2009 00:52:50 -0500
In-Reply-To: <d45a3acc0911171814i310bbd16t8ff3fba2410e9375@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

andrew hendry wrote:
> Hi Max,
> 
> I started looking through the documentation because im looking to use
> tun for X.25 over TCP. The IPX example sounded similar but i couldn't
> get it to work as I was expecting. Looking for a hint in the right
> direction.
Ah, X25 is different.

> There is an old non-mainline patch called x25tap (clone of obsolete
> ethertap). I'm hoping to replace x25tap with tun.
> 
> The old x25tap creates a device like:
> x25tap0   Link encap:generic X.25  HWaddr
>           UP BROADCAST RUNNING NOARP MULTICAST  MTU:1024  Metric:1
>           RX packets:3040785 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:2895530 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:10
>           RX bytes:138787339 (132.3 Mb)  TX bytes:91395983 (87.1 Mb)
> When the x25tap is loaded it has dev->type = ARPHRD_X25, after which
> x.25 routing and AF_X25 sockets can be created.  Along with an XoT
> userspace program which handles some basic headers and TCP port 1998
> it works well.
> 
> If using tun, how does something get registered to handle protocol AF_X25?
> 

I've never tried this personally so ... :). But I just glanced over net/ax25
and drivers/wan/ax25 and it looks TUNSETLINK might work for you.
In other words you want to allocate TUN device (not TAP) and then call
TUNSETLINK with ARPHRD_X25. Seems like you'll get exactly what you need.

Max


> Regards,
> Andrew.
> 
> On Wed, Nov 18, 2009 at 12:40 PM, Max Krasnyansky <maxk@qualcomm.com> wrote:
>> On 11/17/2009 05:30 PM, andrew hendry wrote:
>>> Can the TUNSETIFF ioctl change a tap's protocol to IPX as the
>>> documentation suggests?
>>> I think tun.c would need IFF_IPX_TAP added for it to work as described?
>>> Otherwise tap can only be ptp or ethernet, and there is no way to
>>> route or use AF_IPX.
>> TAP is an Ethernet device. No special handling is required for IPX or for
>> that matter any other protocol. Example seems fine too.
>>
>> Max
>>
>>> Signed-off-by: Andrew Hendry<andrew.hendry@gmail.com>
>>>
>>> --- a/Documentation/networking/tuntap.txt       2009-11-11
>>> 14:03:22.676167648 +1100
>>> +++ b/Documentation/networking/tuntap.txt       2009-11-18
>>> 11:34:18.106647029 +1100
>>> @@ -127,12 +127,14 @@ Ethernet device, which instead of receiv
>>>  media, receives them from user space program and instead of sending
>>>  packets via physical media sends them to the user space program.
>>>
>>> -Let's say that you configured IPX on the tap0, then whenever
>>> -the kernel sends an IPX packet to tap0, it is passed to the application
>>> -(VTun for example). The application encrypts, compresses and sends it to
>>> -the other side over TCP or UDP. The application on the other side
>>> decompresses
>>> -and decrypts the data received and writes the packet to the TAP device,
>>> -the kernel handles the packet like it came from real physical device.
>>> +Let's say for the purpose of example, IPX support was added to tuntap.
>>> +Then whenever the kernel routes an IPX packet to tap0, it is passed to
>>> the
>>> +application reading the file descriptor from /dev/net/tun (VTun for
>>> example).
>>> +The application encrypts, compresses and sends it to the other side over
>>> TCP
>>> +or UDP. The application on the other side decompresses and decrypts the
>>> data
>>> +received and writes the packet to the TAP device, the remote kernel
>>> handles
>>> +the packet like it came from real physical device. The IPX applications
>>> are
>>> +able to communicate as if there was a real IPX network.
>>>
>>>  4. What is the difference between TUN driver and TAP driver?
>>>  TUN works with IP frames. TAP works with Ethernet frames.
>>

