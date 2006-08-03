From: Arnd Hannemann <arnd@arndnet.de>
Subject: Re: problems with e1000 and jumboframes
Date: Thu, 03 Aug 2006 17:32:48 +0200
Message-ID: <44D21720.6080202@arndnet.de>
References: <44D1FEB7.2050703@arndnet.de> <20060803142412.GA14997@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7BIT
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ms-2.rz.RWTH-Aachen.DE ([134.130.3.131]:54983 "EHLO
	ms-dienst.rz.rwth-aachen.de") by vger.kernel.org with ESMTP
	id S964793AbWHCPcv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 11:32:51 -0400
Received: from circe (circe.rz.RWTH-Aachen.DE [134.130.3.36])
 by ms-dienst.rz.rwth-aachen.de
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0J3F00HSNHUEFD@ms-dienst.rz.rwth-aachen.de> for
 netdev@vger.kernel.org; Thu, 03 Aug 2006 17:32:39 +0200 (MEST)
Received: from dustpuppy.kawo2.rwth-aachen.de
 (dustpuppy.kawo2.RWTH-Aachen.DE [134.130.180.5])	by smarthost.rwth-aachen.de
 (8.13.7/8.13.1/1) with ESMTP id k73FWb6K014166	for <netdev@vger.kernel.org>;
 Thu, 03 Aug 2006 17:32:37 +0200
Received: from dustpuppy.kawo2.rwth-aachen.de (localhost [127.0.0.1])
	by dustpuppy.kawo2.rwth-aachen.de (Postfix) with ESMTP id 0387E1FC2A3	for
 <netdev@vger.kernel.org>; Thu, 03 Aug 2006 17:32:37 +0200 (CEST)
In-reply-to: <20060803142412.GA14997@kvack.org>
To: Benjamin LaHaise <bcrl@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Benjamin LaHaise schrieb:
> On Thu, Aug 03, 2006 at 03:48:39PM +0200, Arnd Hannemann wrote:
>> However the box is a VIA Epia MII12000 with 1 GB of Ram and 1 GB of swap
>> enabled, so there should be plenty of memory available. HIGHMEM support
>> is off. The e1000 nic seems to be an 82540EM, which to my knowledge
>> should support jumboframes.
> 
>> However I can't always reproduce this on a freshly booted system, so
>> someone else may be the culprit and leaking pages?
>>
>> Any ideas how to debug this?
> 
> This is memory fragmentation, and all you can do is work around it until 
> the e1000 driver is changed to split jumbo frames up on rx.  Here are a 
> few ideas that should improve things for you:
> 
> 	- switch to a 2GB/2GB split to recover the memory lost to highmem
> 	  (see Processor Type and Features / Memory split)
> 	- increase /proc/sys/vm/min_free_kbytes -- more free memory will 
> 	  improve the odds that enough unfragmented memory is available for 
> 	  incoming network packets
> 
> I hope this helps.

:-) Yes it did. I increased /proc/sys/vm/min_free_kbytes to 65000 and
now it works. Thank you!

> 
> 		-ben

Best regards,
Arnd Hannemann



