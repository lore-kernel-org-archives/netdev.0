From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: at91sam9260 MACB problem with IP fragmentation
Date: Thu, 20 Dec 2012 18:51:15 +0100
Message-ID: <50D35013.9020106@atmel.com>
References: <50C08233.9030905@erwinrol.com> <50C09D2E.8050608@atmel.com> <50D2D7BD.3030801@erwinrol.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>,
	Havard Skinnemoen <havard@skinnemoen.net>,
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
	<matteo.fortini@sadel.it>, netdev <netdev@vger.kernel.org>
To: Erwin Rol <mailinglists@erwinrol.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eusmtp01.atmel.com ([212.144.249.242]:18928 "EHLO
	eusmtp01.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751947Ab2LTRvR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2012 12:51:17 -0500
In-Reply-To: <50D2D7BD.3030801@erwinrol.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/20/2012 10:17 AM, Erwin Rol :
> Hallo Nicolas,
> 
> On 6-12-2012 14:27, Nicolas Ferre wrote:
>> Erwin,
>>
>> On 12/06/2012 12:32 PM, Erwin Rol :
>>> Hello Nicolas, Havard, all,
>>>
>>> I have a very obscure problem with a at91sam9260 board (almost 1 to 1
>>> copy of the Atmel EK).
>>>
>>> The MACB seems to stall when I use large (>2 * MTU) UDP datagrams. The
>>> test case is that a udp echo client (PC) sends datagrams with increasing
>>> length to the AT91 until the max length of the UDP datagram is reached.
>>> When there is no IP fragmentation everything is fine, but when the
>>> datagrams are starting to get fragmented the AT91 will not reply
>>> anymore. But as soon as some network traffic happens it goes on again,
>>> and non of the data is lost.
> 
> <snip>
> 
>>> I tried several kernels including the test version from Nicolas that he
>>> posted on LKML in October. They all show the same effect.
>>
>> [..]
>>
>> It seems that Matteo has the same behavior: check here:
>> http://www.spinics.net/lists/netdev/msg218951.html
> 
> I tried Matteo's patch and it seems to work. But I don't know if the
> patch is really the right solution. I checked again with wireshark and
> it really seems the sending that stalls not the receiving. But as soon
> as a ethernet frame is received the sending "un-stalls". So maybe the
> patch just causes an MACB IRQ at certain moments that causes the sending
> to continue?

Any digging is interesting for me.


>> I am working on the macb driver right now, so I will try to reproduce
>> and track this issue on my side.
> 
> Any luck reproducing it ?

Yes, I see unexpected things happening but as I am connected to a whole
company network so maybe some broadcast packets are unlocking the
interface...
Anyway, I am continuing to investigate.

Best regards,--
Nicolas Ferre
