From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [2.6 patch] unexport icmpmsg_statistics
Date: Wed, 24 Oct 2007 16:52:29 -0400
Message-ID: <471FB08D.9070506@hp.com>
References: <OF4D25AE59.ADF06793-ON8825737E.006DD213-8825737E.006EC6C3@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@kernel.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:56657 "EHLO atlrel7.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752922AbXJXUxB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Oct 2007 16:53:01 -0400
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

Looking at icmp_rcv(), ICMP_MIB_INERRORS is incremented if:
 a) checksum fails
 b) no enough room in skb for icmp header
 c) type out of bound
 and other error conditions while processing ICMP packet.

Are all of these wrong as well?

There are other places that increment this statistic for errors
during processing.

> 
> That's followed by a failed lookup incrementing ICMP_MIB_INERRORS
> which should be an unknown port error in the transport MIB (assuming
> it has one-- it's not an ICMP error; could be an IP error, if the address
> isn't local, rather than unknown port).
> 
> In SCTP, it appears to have similar problems. SCTP errors are not
> ICMP errors, though it perhaps should be calling icmp_send() to
> send one to the offending host for some of the cases.

I'll skip the insufficient buffer space statistic yet, since, per above,
it's not clear which one should be used.

Others, I agree are move ULP errors, but the mibs don't account for those
yet.

-vlad
