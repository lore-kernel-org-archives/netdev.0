From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2] 3c59x: fix PCI resource management
Date: Thu, 02 May 2013 21:40:53 +0400
Message-ID: <5182A525.8020601@cogentembedded.com>
References: <201305020240.34487.sergei.shtylyov@cogentembedded.com> <51819C12.2060103@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, klassert@mathematik.tu-chemnitz.de,
	tedheadster@gmail.com, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f44.google.com ([209.85.215.44]:35353 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759009Ab3EBRlW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 May 2013 13:41:22 -0400
Received: by mail-la0-f44.google.com with SMTP id ed20so786526lab.31
        for <netdev@vger.kernel.org>; Thu, 02 May 2013 10:41:20 -0700 (PDT)
In-Reply-To: <51819C12.2060103@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 02-05-2013 2:49, Sergei Shtylyov wrote:

>> From: Sergei Shtylyov <sshtylyov@ru.mvista.com>

>> The driver wrongly claimed I/O ports at an address returned by pci_iomap() --
>> even if it was passed an MMIO address.  Fix this by claiming/releasing all PCI
>> resources in the PCI driver probe()/remove() methods instead and get rid of the
>> 'must_free_region' flag weirdness (why would Cardbus claim anything for us?).

>> Also, the remove() method was trying to talk to the chip after having disabled
>> its address decoders (at least on x86) -- fix this and while doing it get rid
>> of the useless VORTEX_PCI() invocations.

>> While at it, fix some cases of the overly indented code and the code crossing
>> a 80-column boundary...

>> [akpm@linux-foundation.org: coding-style fixes]
>> Signed-off-by: Sergei Shtylyov <sshtylyov@ru.mvista.com>
>> Cc: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
>> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

>> ---
>> The patch is against David Miller's 'net-next.git' repo.
>> Matthew, please test it on one of your 3c59x EISA boards.
>> Steffen, here's my second try to get this patch past you, the last one was back
>> in 2009...

>      This is mostly a request for testing at this point, I forgot to add [RFT]
> to the subject...

    David and others, your comments are welcome however. The patch probably 
needs some more trimming before it can be considered a pure fix. It has been 
somewhat tested now on EISA (and once more on PCI) board, and as a result of 
testing another one, EISA specific error was reported, fix for which I'm going 
to publish for testing RSN.

WBR, Sergei
