From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: does intel X520-SR(ixgbe) support RSS on single VLAN?
Date: Mon, 24 Jan 2011 09:09:28 -0800
Message-ID: <4D3DB248.5070802@intel.com>
References: <AANLkTinuozfPcAZStV-a=siqcLesqPHnGhVh=QitOnQs@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: Rui <wirelesser@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:2138 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752867Ab1AXRJb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Jan 2011 12:09:31 -0500
In-Reply-To: <AANLkTinuozfPcAZStV-a=siqcLesqPHnGhVh=QitOnQs@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/24/2011 6:18 AM, Rui wrote:
> hi
> does intel X520-SR support RSS on single VLAN?
>
> tested with 3 different vlan id and priority packets
> What I saw is that all packets were always delivered to the same RxQ.
> looks can not get a different RSS index for these packet?
> any setting needed?
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

The X520 should have no problems hashing on a single VLAN tagged frame. 
  However the VLAN will not be a part of the RSS hash.  The  only 
components of the hash are the IPv4/IPv6 source and destination 
addresses, and if the flow is TCP then the port numbers.

I would recommend testing with something like the "netperf -t TCP_CRR" 
test which should open a number of ports and spread traffic out between 
multiple queues.

Thanks,

Alex
