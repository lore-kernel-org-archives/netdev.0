From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] s2io ppc64 fix for readq/writeq
Date: Mon, 06 Nov 2006 04:34:01 -0500
Message-ID: <454F0189.7050008@pobox.com>
References: <1162780109.28571.273.camel@localhost.localdomain>	 <454EE943.6000603@pobox.com>	 <1162800248.28571.296.camel@localhost.localdomain>	 <454EF07B.4010503@pobox.com> <1162803178.28571.300.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:31110 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1423616AbWKFJeE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Nov 2006 04:34:04 -0500
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <1162803178.28571.300.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Benjamin Herrenschmidt wrote:
>> This is why I said "good enough for drivers".  This is _key_.
>>
>> I have run into several [PCI] devices with 64-bit registers, and 
>> __none__ of them had requirements such that the Linux platform code 
>> -must- provide an atomic readq/writeq.  Probably because everybody wants 
>> to support 32-bit platforms with their devices.
>>
>> What you call "fairly bogus" is precisely what drivers need.  These 
>> devices with 64-bit registers just don't need the atomicity that arch 
>> developers harp about :)
> 
> Is there any consistency in that case in which half need to be
> read/written first ? Or none of these ever had side effects ?

Generally the kernel code should write the two 32-bit chunks to the 
memory-mapped region in order (low dword first), and let things take 
care of themselves from there.

That's pretty much the implementation that -every- driver copies, when 
they need readq/writeq to work on a 32-bit platform.

	Jeff



