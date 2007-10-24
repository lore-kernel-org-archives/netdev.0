From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [2.6 patch] unexport icmpmsg_statistics
Date: Wed, 24 Oct 2007 16:24:35 -0400
Message-ID: <471FAA03.9090003@hp.com>
References: <OF4D25AE59.ADF06793-ON8825737E.006DD213-8825737E.006EC6C3@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@kernel.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:46476 "EHLO atlrel9.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752729AbXJXUZI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Oct 2007 16:25:08 -0400
In-Reply-To: <OF4D25AE59.ADF06793-ON8825737E.006DD213-8825737E.006EC6C3@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Stevens wrote:
> I took a look at the DCCP references, and I think they're just
> incrementing the wrong MIB variable -- e.g., it's incrementing
> ICMP_MIB_INERRORS when the skb length is less than the
> header indicates. That's not an ICMP_MIB_INERRORS error,
> that's an IPSTATS_MIB_INHDRERRORS error. ICMP_MIB_INERRORS
> is when you receive an ICMP error packet; an IP header error
> is something else entirely.
> 
> That's followed by a failed lookup incrementing ICMP_MIB_INERRORS
> which should be an unknown port error in the transport MIB (assuming
> it has one-- it's not an ICMP error; could be an IP error, if the address
> isn't local, rather than unknown port).
> 
> In SCTP, it appears to have similar problems. SCTP errors are not
> ICMP errors, though it perhaps should be calling icmp_send() to
> send one to the offending host for some of the cases.
> 
> I haven't seen any ICMP-relevant stats correctly referenced in
> these yet.
> 
> I don't want to patch them directly, since I can't easily test them;
> if someone who works with DCCP and SCTP would like to, I'd
> be happy to review. Any volunteers?

I'll take a look at the SCTP ones.  Thanks for review.

-vlad

> 
>                                                 +-DLS
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

