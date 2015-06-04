From: David Miller <davem@redhat.com>
Subject: Re: [PATCH v6 net-next 00/11] net: Increase inputs to flow_keys
 hashing
Date: Thu, 04 Jun 2015 15:56:25 -0700 (PDT)
Message-ID: <20150604.155625.35211112382842879.davem@redhat.com>
References: <1433434606-527444-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36640 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753746AbbFDW40 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Jun 2015 18:56:26 -0400
In-Reply-To: <1433434606-527444-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Thu, 4 Jun 2015 09:16:35 -0700

> This patch set adds new fields to the flow_keys structure and hashes
> over these fields to get a better flow hash. In particular, these
> patches now include hashing over the full IPv6 addresses in order
> to defend against address spoofing that always results in the
> same hash. The new input also includes the Ethertype, L4 protocol,
> VLAN, flow label, GRE keyid, and MPLS entropy label.
> 
> In order to increase hash inputs, we switch to using jhash2
> which operates an an array of u32's. jhash2 operates on multiples of
> three words. The data in the hash is constructed for that, and there
> are are two variants for IPv4 and Ipv6 addressing. For IPv4 addresses,
> jhash is performed over six u32's and for IPv6 it is done over twelve.
> 
> flow_keys can store either IPv4 or IPv6 addresses (addr_proto field
> is a selector). ipv6_addr_hash is no longer used to convert addresses
> for setting in flow table. For legacy uses of flow keys outside of
> flow_dissector the flow_get_u32_src and flow_get_u32_dst functions
> have been added to get u32 representation representations of addresses
> in flow_keys.
> 
> For flow lables we also eliminate the short circuit in flow_dissector
> for non-zero flow label. The flow label is now considered additional
> input to ports.
> 
> Testing: Ran netperf TCP_RR for 200 flows using IPv4 and IPv6 comparing
> before the patches and with the patches. Did not detect any performance
> degradation.

Series applied, thanks Tom.
