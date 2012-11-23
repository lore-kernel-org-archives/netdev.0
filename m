From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH] 8139cp: set ring address after enabling C+ mode
Date: Fri, 23 Nov 2012 11:53:55 +0800
Message-ID: <50AEF353.8000601@redhat.com>
References: <50AD1972.5080403@pobox.com> <1353529639.26346.164.camel@shinybook.infradead.org> <50ADA05B.2000308@pobox.com> <20121121.233945.2225341904551631404.davem@davemloft.net> <50ADAFB7.7070704@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, dwmw2@infradead.org,
	netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14106 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757496Ab2KWDvB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Nov 2012 22:51:01 -0500
In-Reply-To: <50ADAFB7.7070704@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/22/2012 12:53 PM, Jeff Garzik wrote:
> On 11/21/2012 11:39 PM, David Miller wrote:
>> From: Jeff Garzik <jgarzik@pobox.com>
>> Date: Wed, 21 Nov 2012 22:47:39 -0500
>>
>>> State A:  pre-b01af457, known working
>>> State B:  b01af457, known broken
>>
>> State A is also known buggy on the largest consumer of this driver,
>> the emulated hardware.
>>
>> Please evaluate this realistically.
>
> If the simulator fails to match the hardware, that is a simulator bug.
Resend the mail because it's fail to post to the list yesterday.

CC realtek linux driver mainter (nic_swsd@realtek.com)

The problem the behaviour of the hardware is subtle, and we could not 
just infer it from the datasheet. Another issue is in some situation, 
the datasheet is conflict with what real hardware does, one example is 
the cfg9364 issue mentioned by David ( I also meet it during qemu 
development).

If the hardware always fit garbage into the TxRingAddr register when 
"plus mode" were enabled, it may send something from memory to the wire 
unexpectedly which looks really strange. If it does not change the 
RxRingAddr when enabling C+, another method is to keep setting the rx 
address before C+ enabling but does the tx after.
>
> It is disappointing to work around someone else's software bug in the 
> kernel.
>

Qemu also has some workarounds for the buggy kernels and even in this 
case: it initialize RxRingAddr to 0 and check it during receiving, it  
check whether the addr is still zero ( which may mean the rx ring addr 
were set after the c+ is enabled), it won't do the receiving to prevent 
the corruption. So reverting is safe for rx now.
>     Jeff
>
>
>
