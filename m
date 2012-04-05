From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] net/hsr: Add support for IEC 62439-3 High-availability
 Seamless Redundancy
Date: Wed, 04 Apr 2012 20:17:39 -0400 (EDT)
Message-ID: <20120404.201739.672373176675875061.davem@davemloft.net>
References: <4F71BEAD.5080605@enea.com>
	<20120403113751.21fd0b17@s6510.linuxnetplumber.net>
	<4F7CD4BC.4000006@enea.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org,
	balferreira@googlemail.com, arvid.brodin@xdin.com
To: arvid.brodin@enea.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51258 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754062Ab2DEASH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 20:18:07 -0400
In-Reply-To: <4F7CD4BC.4000006@enea.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arvid Brodin <arvid.brodin@enea.com>
Date: Thu, 5 Apr 2012 01:09:48 +0200

> -		icmp_param.data.icmph	   = *icmp_hdr(skb);
> +		memcpy(&icmp_param.data.icmph, icmp_hdr(skb),
> +						sizeof(icmp_param.data.icmph));

GCC can and will optimize this into an inline assignment, and thus
have the same unaligned access problems, because it determines
alignment based upon the types involved.
