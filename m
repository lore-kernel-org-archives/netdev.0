From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH v2] net/macb: Use non-coherent memory for rx buffers
Date: Mon, 3 Dec 2012 14:21:10 +0100
Message-ID: <50BCA746.1020705@atmel.com>
References: <CAGhQ9VwWmP_B17LnAEqDHcL8Yd-s0C-Bf35z3+=vnJmK_NoCSw@mail.gmail.com> <1354536876-6274-1-git-send-email-nicolas.ferre@atmel.com> <AE90C24D6B3A694183C094C60CF0A2F6026B70D5@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>,
	Joachim Eastwood <manabian@gmail.com>,
	Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>,
	Havard Skinnemoen <havard@skinnemoen.net>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B70D5@saturn3.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/03/2012 01:43 PM, David Laight :
>> Allocate regular pages to use as backing for the RX ring and use the
>> DMA API to sync the caches. This should give a bit better performance
>> since it allows the CPU to do burst transfers from memory. It is also
>> a necessary step on the way to reduce the amount of copying done by
>> the driver.
> 
> I've not tried to understand the patches, but you have to be
> very careful using non-snooped memory for descriptor rings.
> No amount of DMA API calls can sort out some of the issues.

David,

Maybe I have not described the patch properly but the non-coherent
memory is not used for descriptor rings. It is used for DMA buffers
pointed out by descriptors (that are allocated as coherent memory).

As buffers are filled up by the interface DMA and then, afterwards, used
by the driver to pass data to the net layer, it seems to me that the use
of non-coherent memory is sensible.

Do you still have reluctance with this patch?

Best regards,
-- 
Nicolas Ferre
