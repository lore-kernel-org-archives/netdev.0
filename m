From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH] Intel IXP4xx network drivers v.2 - Ethernet and HSS
Date: Tue, 08 May 2007 16:31:12 +0200
Message-ID: <m3fy6775fz.fsf@maximus.localdomain>
References: <m3abwhcy74.fsf@maximus.localdomain>
	<m3vef5biob.fsf@maximus.localdomain>
	<5BB7E1AB-5CE1-43C8-8CE3-E0DE0236BD09@cam.ac.uk>
	<m3hcqoa772.fsf@maximus.localdomain>
	<86D26EBE-5899-468F-9C79-23E83E0DE04B@cam.ac.uk>
	<m33b289zku.fsf@maximus.localdomain>
	<m3zm4g3yed.fsf_-_@maximus.localdomain>
	<20070508113735.GB32055@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael-Luke Jones <mlj28@cam.ac.uk>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>,
	Russell King <rmk@arm.linux.org.uk>,
	ARM Linux Mailing List
	<linux-arm-kernel@lists.arm.linux.org.uk>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:55951 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S968127AbXEHObO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2007 10:31:14 -0400
In-Reply-To: <20070508113735.GB32055@xi.wantstofly.org> (Lennert Buytenhek's message of "Tue, 8 May 2007 13:37:35 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Lennert Buytenhek <buytenh@wantstofly.org> writes:

>> +/* Built-in 10/100 Ethernet MAC interfaces */
>> +static struct mac_plat_info ixdp425_plat_mac[] = {
>> +	{
>> +		.phy		= 0,
>> +		.rxq		= 3,
>> +	}, {
>> +		.phy		= 1,
>> +		.rxq		= 4,
>> +	}
>> +};
>
> As with Christian's driver (I'm feeling like a bit of a broken record
> here :-), putting knowledge of which queue to use (which is firmware-
> specific) in the _board_ support file is almost certainly wrong.
>
> I would just put the port number in there, and let the ethernet
> driver map the port number to the hardware queue number.  After all,
> the ethernet driver knows which queues the firmware uses, while the
> board support code doesn't.

No, quite the opposite. The board code knows its set of hardware
interfaces etc. and can let Ethernet driver use, say, HSS queues.
The driver can't know that.

It would make sense if we had many queues, but it doesn't seem
the case (perhaps the upper queues could be used for some
purposes, but Intel's code doesn't use them either and they
probably know better).

>> +static inline void set_regbits(u32 bits, u32 __iomem *reg)
>> +{
>> +	__raw_writel(__raw_readl(reg) | bits, reg);
>> +}
>> +static inline void clr_regbits(u32 bits, u32 __iomem *reg)
>> +{
>> +	__raw_writel(__raw_readl(reg) & ~bits, reg);
>> +}
>
> I generally discourage the use of such wrappers, as it often makes
> people forget that the set and clear operations are not atomic, and
> it ignores the fact that some of the other bits in the register you
> are modifying might have side-effects.

Without them the code in question is hardly readable, I pick the need
to remember about non-atomicity and possible side effects instead :-)

I've outlined the current versions in a separate mail, generally
2 patches are marked "v.2" and one "v.3".
-- 
Krzysztof Halasa
