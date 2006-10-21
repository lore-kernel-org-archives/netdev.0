From: stephen@dino.dnsalias.com (Stephen J. Bevan)
Subject: Re: [RFC] Ethernet Cheap Cryptography
Date: Fri, 20 Oct 2006 19:17:42 -0700
Message-ID: <17721.33606.219025.313449@localhost.localdomain>
References: <17718.63424.509719.492216@localhost.localdomain>
	<eh87aq$71t$1@sea.gmane.org>
	<17720.12801.843076.819750@localhost.localdomain>
	<20061019.195921.31639913.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@dino.dnsalias.com, pjf@asn.pl, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from S010600014e000000.vc.shawcable.net ([70.79.40.36]:51251 "EHLO
	dino.dnsalias.com") by vger.kernel.org with ESMTP id S1030380AbWJUCSp
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Oct 2006 22:18:45 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061019.195921.31639913.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller writes:
 > From: stephen@dino.dnsalias.com (Stephen J. Bevan)
 > Date: Thu, 19 Oct 2006 19:18:41 -0700
 > 
 > > Pawel Foremski writes:
 > >  > Secondly, IPsec won't decrease MSS in TCP encapsulated in PPPoE
 > >  > traffic, for example. 
 > > 
 > > Various, commercial, IPsec products decrease the MSS for TCP
 > > encapsulated in PPPoE.  I've not checked the Linux 2.6 IPsec code to
 > > see if it does or if it can easily be made to.
 > 
 > Linux will for local TCP connections over IPSEC transports since it
 > knows the path MTU, for IPSEC gateways the source system will adjust
 > the MSS after it notes via path-MTU what the decreased MTU is.

path-MTU gets interesting[1] in the context of an an IPsec gateway
(i.e. tunnel mode IPsec) and there is definitely variability as to how
reliably an ICMP will be returned in the case that the MTU is exceeded
somewhere between the two endpoints.  Throw in port/protocol based
selectors[2] or IPv4(IPv6) traffic encrypted with an IPv6(IPv4)
header[3] and the chances of success go down.

Users ussually don't tend to care whose IPsec is at fault, they just
want things to work.  Thus, having tunnel mode IPsec alter the MSS (of
non-local traffic) to take account of the encryption (or PPPoE,
... etc.) overhead smooths over most fragmentation issues.

----------
[1] as detailed in the length Appendix B of RFC 2401.

[2] some IPsec implementation won't correctly match an ICMP up against
    port/protocol based selectors and so the ICMP is lost.

[3] mapping the DF bit is left to implementations, some reset the DF
    bit and so just fragment.
