From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC] net/hsr: Add support for IEC 62439-3 High-availability
 Seamless Redundancy
Date: Thu, 5 Apr 2012 20:21:08 +0100
Message-ID: <1333653668.2652.13.camel@bwh-desktop.uk.solarflarecom.com>
References: <4F71BEAD.5080605@enea.com>
	 <20120403113751.21fd0b17@s6510.linuxnetplumber.net>
	 <4F7CD4BC.4000006@enea.com>
	 <20120404.201739.672373176675875061.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <arvid.brodin@enea.com>, <shemminger@vyatta.com>,
	<netdev@vger.kernel.org>, <balferreira@googlemail.com>,
	<arvid.brodin@xdin.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:33217 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755849Ab2DETVM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2012 15:21:12 -0400
In-Reply-To: <20120404.201739.672373176675875061.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-04-04 at 20:17 -0400, David Miller wrote:
> From: Arvid Brodin <arvid.brodin@enea.com>
> Date: Thu, 5 Apr 2012 01:09:48 +0200
> 
> > -		icmp_param.data.icmph	   = *icmp_hdr(skb);
> > +		memcpy(&icmp_param.data.icmph, icmp_hdr(skb),
> > +						sizeof(icmp_param.data.icmph));
> 
> GCC can and will optimize this into an inline assignment, and thus
> have the same unaligned access problems, because it determines
> alignment based upon the types involved.

So presumably icmp_hdr() should be changed to skb_transport_header().

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
