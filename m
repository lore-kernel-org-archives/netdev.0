From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/14] nes: device structures and defines
Date: Wed, 08 Aug 2007 12:19:09 -0400
Message-ID: <46B9ECFD.1070700@garzik.org>
References: <200708080045.l780jE9E004667@neteffect.com>	<46B918BA.2020400@garzik.org> <p73hcnarykt.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ggrundstrom@neteffect.com, rdreier@cisco.com,
	ewg@lists.openfabrics.org, netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41316 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932730AbXHHQTQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Aug 2007 12:19:16 -0400
In-Reply-To: <p73hcnarykt.fsf@bingen.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
> Jeff Garzik <jeff@garzik.org> writes:
>>> +			val, reg_index, addr, addr+4); */
>>> +	writel(cpu_to_le32(reg_index), addr);
>>> +	writel(cpu_to_le32(val),(u8 *)addr + 4);
>> wrong -- endian conversion macros not needed with writel()
> 
> Are you sure?

Yes.

read[bwl] and write[bwl] are always defined in terms of the 
little-endian PCI bus.  This has been true since my first days in the 
kernel ages (decade+) ago, when we had a long discussion about it with 
regards to framebuffer drivers.

If you want to skip barriers and endian conversions, __raw_write[bwl]() 
exists.

The rare exceptions are a few embedded arches that implemented writel() 
for a non-PCI bus.  Those cases need to be renamed to mybus_writel(), 
but at least they do not interfere with mainstream drivers and APIs.


> I don't think that's true. e.g. powerpc writel 
> doesn't convert endian

Incorrect -- read the code.  PPC most certainly does convert endian.

Ten years ago Linus said something along the lines of "writel() means 
PCI means little endian.  period."  ;-)

	Jeff


