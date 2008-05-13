From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [RFC] [DCCP]: Deprecate SOCK_DCCP in favour of SOCK_DGRAM
Date: Tue, 13 May 2008 18:03:25 +0100
Message-ID: <20080513170325.GB11499@gerrit.erg.abdn.ac.uk>
References: <20080513093718.GA24185@gerrit.erg.abdn.ac.uk> <OFDBD6E282.6F00998A-ON88257448.0056D40D-88257448.0057105E@us.ibm.com> <20080513162325.GF15306@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Arnaldo Carvalho de Melo <acme@redhat.com>,
	David Stevens <dlstevens@us.ibm.com>,
	David Miller <davem@davemloft.net>, dccp@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:33820 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755955AbYEMRHx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 May 2008 13:07:53 -0400
Content-Disposition: inline
In-Reply-To: <20080513162325.GF15306@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| > the existing stuff alone, and then requiring programs that want to use
| > getaddrinfo to use it that way?
| 
| I wonder what is the problem with doing what I did when adding support
| for DCCP in ttcp, or for AF_LLC in ssh, ncftp, vsftpd, etc, i.e.
| getaddrinfo/getnameinfo wrappers that look if SOCK_DCCP or AF_LLC are
| being asked for and doing the right thing.
| 
Using work-arounds is brittle and frustrating when the API behaviour
suddenly changes. My experience of using such a wrapper was:

 * it passed UDP(-Lite), TCP through without changing the socket type;
 * when passed DCCP, it set the socket type to 0, to avoid `ai_socktype
   not supported' getaddrinfo error;
 * this used to work fine until about January, when something in the
   lookup machinery for dual-stack hosts changed:
   - before, AF_UNSPEC + ai_socktype=0 put IPv6 first into the result list,
   - now the the result order is reversed (IPv4 sockets are returned first)
 * so maybe "pretending to be UDP" (ai_socktype=SOCK_DGRAM) is a better
   workaround (at least it worked until this afternoon :)


| What would be the problem of SOCK_DCCP being handled in glibc in such a
| fashion?
That is probably the best and most robust solution one can think of.

Even the suggestion of changing to SOCK_DGRAM+IPPROTO_DCCP is just another
work-around and, as David and Remi confirmed, a bad one at that.

Gerrit
