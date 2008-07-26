From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [RFC] sctp/tcp: Question -- ICMPv4 length check (not)
	redundant?
Date: Sat, 26 Jul 2008 09:10:07 +0100
Message-ID: <20080726081007.GA7299@gerrit.erg.abdn.ac.uk>
References: <488A88C5.1070105@hp.com> <20080725.213857.160776686.davem@davemloft.net> <20080726070308.GA4674@gerrit.erg.abdn.ac.uk> <20080726.003617.265743493.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vladislav.yasevich@hp.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:34395 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750957AbYGZIKV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Jul 2008 04:10:21 -0400
Content-Disposition: inline
In-Reply-To: <20080726.003617.265743493.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| What if the lower protocol doesn't have a header that it
| at least 8 bytes? :-)
| 
| I think that's yet another reason why the check and counter bump were
| originally down in the per-protocol hander.
| 
The only reason I can think of is RFC 1122, 3.2.2:
 "Every ICMP error message includes the Internet header and at
  least the first 8 data octets of the datagram that triggered
  the error; more than 8 octets MAY be sent [...]"

But for ICMPv6 the requirement is less strict (RFC 4443, 2.4):
 "Every ICMPv6 error message (type < 128) MUST include as much of
  the IPv6 offending (invoking) packet (the packet that caused the
  error) as possible without making the error message packet exceed
  the minimum IPv6 MTU [IPv6]."
