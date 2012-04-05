From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] net/hsr: Add support for IEC 62439-3 High-availability
 Seamless Redundancy
Date: Thu, 05 Apr 2012 18:31:43 -0400 (EDT)
Message-ID: <20120405.183143.727226239038853914.davem@davemloft.net>
References: <4F7CD4BC.4000006@enea.com>
	<20120404.201739.672373176675875061.davem@davemloft.net>
	<1333653668.2652.13.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arvid.brodin@enea.com, shemminger@vyatta.com,
	netdev@vger.kernel.org, balferreira@googlemail.com,
	arvid.brodin@xdin.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60650 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755368Ab2DEWcS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2012 18:32:18 -0400
In-Reply-To: <1333653668.2652.13.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 5 Apr 2012 20:21:08 +0100

> On Wed, 2012-04-04 at 20:17 -0400, David Miller wrote:
>> From: Arvid Brodin <arvid.brodin@enea.com>
>> Date: Thu, 5 Apr 2012 01:09:48 +0200
>> 
>> > -		icmp_param.data.icmph	   = *icmp_hdr(skb);
>> > +		memcpy(&icmp_param.data.icmph, icmp_hdr(skb),
>> > +						sizeof(icmp_param.data.icmph));
>> 
>> GCC can and will optimize this into an inline assignment, and thus
>> have the same unaligned access problems, because it determines
>> alignment based upon the types involved.
> 
> So presumably icmp_hdr() should be changed to skb_transport_header().

I would not say so.  Otherwise we introduce ugly casts everywhere.
