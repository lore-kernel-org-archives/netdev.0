From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [RFC] [DCCP]: Deprecate SOCK_DCCP in favour of SOCK_DGRAM
Date: Tue, 13 May 2008 14:46:31 +0100
Message-ID: <20080513134631.GA7024@gerrit.erg.abdn.ac.uk>
References: <20080513072853.GB4514@gerrit.erg.abdn.ac.uk> <48a00ddc692de4b7b71273614e61ab17@chewa.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, dccp@vger.kernel.org,
	Arnaldo <acme@redhat.com>
To: Remi Denis-Courmont <rdenis@simphalempin.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:54892 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752299AbYEMNqx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 May 2008 09:46:53 -0400
Content-Disposition: inline
In-Reply-To: <48a00ddc692de4b7b71273614e61ab17@chewa.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| 
| DCCP clearly fails the POSIX definition of SOCK_DGRAM in different ways.
| 
| I think this is not a good idea.
| 
Thanks for the clarification. Even in Posix, datagram = connection-less.
Plus the issues with older kernel releases. Question resolved, no SOCK_DGRAM.


| > It also relieves the libc writers from having to support another socket
| > type.
| 
| As long as SOCK_DCCP-or-whatever is not automatically selected when
| ai_socktype is nul, this should be both easy to implement in libc *and*
| backward compatible (applications will not try to use DCCP implicitly).
| 
There are two possibilities:
 * as additional supported protocol (there are many new transport
   protocols, perhaps there is some kind of modular support),
 * if DCCP service codes are part of the lookup, then getting library
   support can take longer (algorithm changes).

Both may take a while until available. In the meantime it would be good
to find some smart workaround for getaddrinfo, as changes in the internals
so far required to fix applications several times.
