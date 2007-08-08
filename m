From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/14] nes: device structures and defines
Date: Wed, 08 Aug 2007 12:33:24 -0400
Message-ID: <46B9F054.4030000@garzik.org>
References: <200708080045.l780jE9E004667@neteffect.com> <200708081555.03588.mb@bu3sch.de> <aday7gmov8o.fsf@cisco.com> <200708081830.20129.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <rdreier@cisco.com>,
	Andi Kleen <andi@firstfloor.org>, ggrundstrom@neteffect.com,
	ewg@lists.openfabrics.org, netdev@vger.kernel.org
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:33003 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936788AbXHHQd3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Aug 2007 12:33:29 -0400
In-Reply-To: <200708081830.20129.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Buesch wrote:
> On Wednesday 08 August 2007 18:18:31 Roland Dreier wrote:
>>  > But there are indeed a few cases that look wrong.
>>
>> yes...
>>
>>  > arch/x86_64/kernel/pci-calgary.c:       writel(cpu_to_be32(val), target);
>>
>> eg this almost certainly wants to be
>>
>> 	writel(swab32(val), target);
>>
>> or something equivalent like
>>
>> 	__raw_writel(cpu_to_be32(val), target);
>> 	/* plus some suffficent memory ordering */
>>
>>  - R.
>>
>>
> 
> certainly, yes.
> Most likely the __raw_writel variant is portable, but I am not
> sure. Anybody sure?

Yes, it's portable.  You must however be aware of the guarantees that 
writel() provides and __raw_writel() does not:  no barriers or flushes, 
no endian conversions, no ordering constraints, ...  Probably a few more 
details I'm forgetting too :)

	Jeff



