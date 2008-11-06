From: "Mike Frysinger" <vapier.adi@gmail.com>
Subject: Re: [PATCH] SSB: make it depend on PCI
Date: Thu, 6 Nov 2008 06:26:36 -0500
Message-ID: <8bd0f97a0811060326n5bcfc17fm5b5a65b12e71ea61@mail.gmail.com>
References: <1225965082-31462-1-git-send-email-vapier@gentoo.org>
	 <1225969620.3619.204.camel@johannes.berg>
	 <8bd0f97a0811060315j7d11e1a7p257a4a1bea640f7b@mail.gmail.com>
	 <1225970573.3619.208.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Mike Frysinger" <vapier@gentoo.org>,
	"Michael Buesch" <mb@bu3sch.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Johannes Berg" <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.228]:40577 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753326AbYKFL0h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2008 06:26:37 -0500
In-Reply-To: <1225970573.3619.208.camel@johannes.berg>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 6, 2008 at 06:22, Johannes Berg wrote:
> On Thu, 2008-11-06 at 06:15 -0500, Mike Frysinger wrote:
>> while that may be the intent, it doesnt work today.
>>
>> drivers/ssb/main.c always includes linux/ssb/ssb.h
>>
>> linux/ssb/ssb.h always calls pci_dma_* functions
>>
>> arches that do not support PCI fail to build:
>>   CC      drivers/ssb/main.o
>> In file included from drivers/ssb/ssb_private.h:5,
>>                  from drivers/ssb/main.c:12:
>> include/linux/ssb/ssb.h: In function 'ssb_dma_mapping_error':
>> include/linux/ssb/ssb.h:430: error: implicit declaration of function 'pci_dma_mapping_error'
>> include/linux/ssb/ssb.h: In function 'ssb_dma_sync_single_for_cpu':
>> include/linux/ssb/ssb.h:475: error: implicit declaration of function 'pci_dma_sync_single_for_cpu'
>> include/linux/ssb/ssb.h: In function 'ssb_dma_sync_single_for_device':
>> include/linux/ssb/ssb.h:493: error: implicit declaration of function 'pci_dma_sync_single_for_device'
>> include/linux/ssb/ssb.h: In function 'ssb_dma_sync_single_range_for_cpu':
>> include/linux/ssb/ssb.h:517: error: implicit declaration of function 'dma_sync_single_range_for_cpu'
>> include/linux/ssb/ssb.h: In function 'ssb_dma_sync_single_range_for_device':
>> include/linux/ssb/ssb.h:538: error: implicit declaration of function 'dma_sync_single_range_for_device'
>> drivers/ssb/main.c: In function 'ssb_dma_set_mask':
>> drivers/ssb/main.c:1183: error: implicit declaration of function 'dma_set_mask'
>
>
> That seems odd, shouldn't at least the dma_sync_* functions and
> dma_set_mask be supported?

i'm highlighting the pci-specific functions.  the common dma functions
missing are not a ssb problem, so ignore those ;).
-mike
