From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: fix bad checksum on IPv6 when NAT is performed
Date: Tue, 6 Oct 2015 16:28:44 +0200
Message-ID: <20151006142844.GA14169@salvia>
References: <1444140652.14655.340.camel@sakura.staff.proxad.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, davem <davem@davemloft.net>,
	kaber <kaber@trash.net>
To: Maxime Bizon <mbizon@freebox.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:36714 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751318AbbJFOVs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Oct 2015 10:21:48 -0400
Content-Disposition: inline
In-Reply-To: <1444140652.14655.340.camel@sakura.staff.proxad.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 06, 2015 at 04:10:52PM +0200, Maxime Bizon wrote:
> 
> With this setup:
> 
> * non IPv6 checksumming capable network hardware
> * GRO off
> * IPv6 SNAT
> 
> I get this when I receive an UDPv6 reply: "<unknown>: hw csum failure"
> 
> Call trace:
> 
> * nf_ip6_checksum() calls __skb_checksum_complete()
> * nf_nat_ipv6_csum_update() & nf_nat_ipv6_manip_pkt()
> * __udp6_lib_rcv() => udp6_csum_init()
> * __skb_checksum_validate_complete() "fastpath" fails because
>   skb->csum is incorrect.
> * udpv6_recvmsg() => skb_copy_and_csum_datagram_msg()
> 
> The last call computes a valid checksum despite CHECKSUM_COMPLETE and
> triggers the warning.
> 
> When we perform NAT on IPv4, we also update the IPv4 checksum, so
> there is no side effect on skb->csum (since the csum over a valid IPv4
> header area is zero).
> 
> But IPv6 doesn't have such header checksum, so when performing NAT we need to
> update skb->csum.

Please, resubmit and Cc netfilter-devel@vger.kernel.org.

Thanks.
