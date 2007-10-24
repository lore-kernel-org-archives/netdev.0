From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [2.6 patch] unexport icmpmsg_statistics
Date: Wed, 24 Oct 2007 17:00:16 -0400
Message-ID: <471FB260.8090503@hp.com>
References: <OF03E20988.736A2E51-ON8825737E.007067FE-8825737E.0071B902@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@kernel.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:51730 "EHLO atlrel9.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753427AbXJXVAs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Oct 2007 17:00:48 -0400
In-Reply-To: <OF03E20988.736A2E51-ON8825737E.007067FE-8825737E.0071B902@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Stevens wrote:
> My bad -- I see what it's doing, and it looks ok after all.
> 
> I thought I saw an INMSGS (but didn't).  These are ICMP errors that
> went through icmp_rcv() and were counted correctly before getting
> to the protocol error handlers. These are failures due mostly to not
> having enough, or the right protocol info in the error packet being
> handled. I'm not sure I'd count those as ICMP errors, since the
> ICMP header itself is correct, but ok...
> 
> SCTP doesn't look so bad, though I think the references are
> still questionable (but debatable) as ICMP errors.
> 
> sctp_v4_err is incrementing ICMP_MIB_INERRORS if there
> isn't enough IP header to find the ports, I see. I'm not sure
> that counts as an ICMP error, but it's not so terrible.
> 
> It's doing the same thing if a lookup fails to match "vtag" from
> the encapsulated error packet. Again, I don't know that those
> are ICMP errors (which normally are something wrong with
> the ICMP header).

This particular case is the one that bugs the most, but that
error matches best.

Seems like all ULPs treat socket lookup error as ICMP_MIB_INERRORS
(tcp, udp, sctp, dccp).

SCTP is a little special in that in needs to check one one piece
of data (the 'vtag') to correctly identify the connection.
If that piece doesn't match, we treat that as the same error.

-vlad
