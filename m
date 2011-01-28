From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] gianfar: Fall back to software tcp/udp checksum on
 oldercontrollers
Date: Fri, 28 Jan 2011 11:59:39 -0800 (PST)
Message-ID: <20110128.115939.104064843.davem@davemloft.net>
References: <640295.36173.qm@web37608.mail.mud.yahoo.com>
	<AE90C24D6B3A694183C094C60CF0A2F6D8AC2E@saturn3.aculab.com>
	<20110128105610.4a518456@udp111988uds.am.freescale.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David.Laight@ACULAB.COM, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org
To: scottwood@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33568
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751278Ab1A1T7F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jan 2011 14:59:05 -0500
In-Reply-To: <20110128105610.4a518456@udp111988uds.am.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Wood <scottwood@freescale.com>
Date: Fri, 28 Jan 2011 10:56:10 -0600

> On Fri, 28 Jan 2011 09:10:46 +0000
> David Laight <David.Laight@ACULAB.COM> wrote:
> 
>>  
>> > +		if (unlikely(gfar_has_errata(priv, GFAR_ERRATA_12)
>> > +			     && ((unsigned long)fcb % 0x20) > 0x18)) {
>> 
>> You need to check the generated code, but I think you need:
>> 
>>     if (unlikely(gfar_has_errata(priv, GFAR_ERRATA_12))
>> 	     && unlikely(((unsigned long)fcb % 0x20) > 0x18))
>> 
>> ie unlikely() around both the primitive comparisons.
> 
> Is the first condition actually unlikely?  If you've got affected
> hardware, you'll hit it every time.
> 
> If packets with the problematic alignment are rare, seems like it'd be
> better to check that first.

In cases like this gfar_has_errata() case, better to leave it's
likelyhood unmarked.

And yes, since it's cheaper, checking the alignment should be done
first.
