From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/6] xen-netfront: reduce gso_max_size to account for
 ethernet header
Date: Mon, 25 Mar 2013 20:49:09 +0000
Message-ID: <1364244549.2710.12.camel@bwh-desktop.uk.solarflarecom.com>
References: <1364209702-12437-3-git-send-email-wei.liu2@citrix.com>
	 <20130325.121809.2023305728304341952.davem@davemloft.net>
	 <1364230472.29473.21.camel@edumazet-glaptop>
	 <20130325.125949.1046297562456662826.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <eric.dumazet@gmail.com>, <wei.liu2@citrix.com>,
	<xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	<ian.campbell@citrix.com>, <annie.li@oracle.com>,
	<konrad.wilk@oracle.com>, <david.vrabel@citrix.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:35781 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932238Ab3CYUtO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Mar 2013 16:49:14 -0400
In-Reply-To: <20130325.125949.1046297562456662826.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-03-25 at 12:59 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 25 Mar 2013 09:54:32 -0700
> 
> > On Mon, 2013-03-25 at 12:18 -0400, David Miller wrote:
> > 
> >> 
> >> This is effectively the default already, you don't need to change this
> >> value explicitly.
> >> 
> >> ->gso_max_size is set by default to 65536 and then TCP performs this
> >> calculation:
> >> 
> >>                 xmit_size_goal = ((sk->sk_gso_max_size - 1) -                          
> >>                                   inet_csk(sk)->icsk_af_ops->net_header_len -          
> >>                                   inet_csk(sk)->icsk_ext_hdr_len -                     
> >>                                   tp->tcp_header_len);                                 
> >> 
> >> thereby making it adhere to your limits just fine.
> > 
> > For locally generated TCP traffic this is the case.
> 
> Right, and also any other piece of code that is not interpreting the
> gso_max_size value the same way (as "(x - 1) - sizeof_headers") would
> need to be fixed.
[...]

tcp_tso_should_defer() also ignores headers, though I don't think the
check is particularly critical in that case.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
