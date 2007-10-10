From: Brian Haley <brian.haley@hp.com>
Subject: Re: [IPv6] Update setsockopt(IPV6_MULTICAST_IF) to support RFC 3493
Date: Wed, 10 Oct 2007 17:20:45 -0400
Message-ID: <470D422D.5070403@hp.com>
References: <OF75CC6365.1CACD211-ON88257370.0071BBE2-88257370.0071F400@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netdev-owner@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:40973 "EHLO atlrel6.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756431AbXJJVVt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Oct 2007 17:21:49 -0400
In-Reply-To: <OF75CC6365.1CACD211-ON88257370.0071BBE2-88257370.0071F400@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Stevens wrote:
> What about just checking for 0 in the later test?
> 
>         if (val && __dev_get_by_index(val) == NULL) {

We could fail the next check right before that though:

           if (sk->sk_bound_dev_if && sk->sk_bound_dev_if != val)
                   goto e_inval;

I just mimicked what the IPv4 code does in do_ip_setsockopt().

-Brian
