From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [RFC] [DCCP]: Deprecate SOCK_DCCP in favour of SOCK_DGRAM
Date: Wed, 14 May 2008 19:00:11 +0100
Message-ID: <20080514180011.GA1661@gerrit.erg.abdn.ac.uk>
References: <20080513162325.GF15306@ghostprotocols.net> <20080513170325.GB11499@gerrit.erg.abdn.ac.uk> <200805132037.39580.rdenis@simphalempin.com> <4829E87F.1070006@redhat.com> <20080514080942.GB4462@gerrit.erg.abdn.ac.uk> <482AF1DB.1060608@redhat.com> <20080514144518.GA30578@gerrit.erg.abdn.ac.uk> <482B0DF8.9060001@redhat.com> <20080514172204.GA1036@gerrit.erg.abdn.ac.uk> <482B24CD.2040209@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: R?mi Denis-Courmont <rdenis@simphalempin.com>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	David Stevens <dlstevens@us.ibm.com>,
	David Miller <davem@davemloft.net>, dccp@vger.kernel.org,
	netdev@vger.kernel.org
To: Ulrich Drepper <drepper@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:62892 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757503AbYENSE3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2008 14:04:29 -0400
Content-Disposition: inline
In-Reply-To: <482B24CD.2040209@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| > But either is important be considered when a user unambiguously specifies
| > ai_socktype and/or ai_protocol; to avoid bad/brittle workarounds.
| 
| OK, I added the support.  Will be in glibc 2.9.
| 
This is really good news :)

| But what about $subject?  What is the story with SOCK_DCCP?  I added it
| now but if it's going away I'd rather remove it.
| 
No, I don't think it will be deprecated, it has been part of several kernel
releases in this form already and there was no support in the thread for
changing SOCK_DCCP.

AS I am guilty of $subject, the story is that the initial suggestion to
avoid the trouble with getaddrinfo() by changing the socket type to
SOCK_DGRAM, since then presumably an address would be returned. 

This proved an even poorer workaround than any of the existing ones, in
particular since it collides with the (Posix) definition of SOCK_DGRAM,
and has been part of kernel releases.

Eventually Arnaldo made the most sensible suggestion of why not solving
the trouble at the root and update glibc, which is how a message with
this subject reached your inbox. This had wider support and I can't
think of a better way to solve the problem. 

Hence many thanks indeed, as the absence of proper DCCP/UDP-Lite support
in getaddrinfo() has so far caused quite some grief/frustration.

Gerrit
