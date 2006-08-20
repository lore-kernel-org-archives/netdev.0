From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [RFC] HOWTO use NAPI to reduce TX interrupts
Date: Sat, 19 Aug 2006 18:31:43 -0700
Message-ID: <44E7BB7F.7030204@osdl.org>
References: <20060818220700.GG26889@austin.ibm.com> <20060818222657.GL26889@austin.ibm.com> <200608190103.05649.arnd@arndb.de> <200608190256.26373.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, akpm@osdl.org,
	James K Lewis <jklewis@us.ibm.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Jeff Garzik <jgarzik@pobox.com>,
	Jens Osterkamp <Jens.Osterkamp@de.ibm.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:3476 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751267AbWHSBb4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2006 21:31:56 -0400
To: Arnd Bergmann <arnd@arndb.de>
In-Reply-To: <200608190256.26373.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnd Bergmann wrote:
> On Saturday 19 August 2006 01:03, Arnd Bergmann wrote:
>   
>> Someone should probably document that in 
>> Documentation/networking/NAPI_HOWTO.txt, I might end up doing that
>> once we get it right for spidernet
>>     

The reason reclaim via poll() is efficient is because it avoid causing a 
softirq that is
necessary when skb_free_irq() is done. Instead it reuses the softirq 
from the poll()
routine. Like all Rx NAPI, using poll() for reclaim means:
    + aggregating multiple frames in one irq
    - increased overhead of twiddling with the IRQ mask
    - more ways to get driver stuck
   
Some drivers do all their irq work in the poll() routine (including PHY 
handling).
This is good if reading the IRQ status does an auto mask operation.

The whole NAPI documentation area is a mess and needs a good writer
to do some major restructuring. It should also be split into reference 
information,
tutorial and guide sections.

