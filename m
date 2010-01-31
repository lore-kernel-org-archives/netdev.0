From: Michael Breuer <mbreuer@majjas.com>
Subject: Re: [PATCH] sky2:  receive dma mapping error handling
Date: Sun, 31 Jan 2010 13:50:33 -0500
Message-ID: <4B65D0F9.2020602@majjas.com>
References: <4B61ADF1.7060705@majjas.com> <4B61BEA4.1030905@majjas.com>
 <20100128090835.0d93e53a@nehalam> <4B61DB79.4080703@majjas.com>
 <20100128223447.GC3109@del.dom.local> <4B621316.8070308@majjas.com>
 <20100128225621.GD3109@del.dom.local> <4B6216B9.1010802@majjas.com>
 <20100128153643.0fca3c51@nehalam> <4B645EF4.4050701@majjas.com>
 <20100131003449.GA11935@del.dom.local> <4B650D53.2010607@majjas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Michael Chan <mchan@broadcom.com>,
	Don Fry <pcnet32@verizon.net>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Matt Carlson <mcarlson@broadcom.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753197Ab0AaSuo@vger.kernel.org>
In-reply-to: <4B650D53.2010607@majjas.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/30/2010 11:55 PM, Michael Breuer wrote:
> On 01/30/2010 07:34 PM, Jarek Poplawski wrote:
>>
>> Could you try the patch below to show maybe some other users of
>> dma-debug entries?
>>
>> Jarek P.
>> ---
>>
> With the default # entries & dma_debug_driver=sky2:
>
> 6:00 is eth0 & 4:00 is eth1.
>
> Jan 30 23:53:14 mail kernel: DMA-API: 0000:06:00.0: entries: 31961
> ...
>
I put a printk as a third else case in sky2_tx_unmap. Looks like the 
issue is that a large number (perhaps all) calls to sky2_tx_unmap have 
re->flags set to neither TX_MAP_SINGLE or TX_MAP_PAGE. Thus the elements 
are never being unmapped.

I suspect that the system collapses when using DMAR sooner than if not 
using DMAR. Probably some hardware limitation on the number of mapped 
elements that is less than the software limitation. I don't see at 
present how a ring element can ever get to this code without re->flags 
being set to one or the other.
