From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [RFC] [DCCP]: Deprecate SOCK_DCCP in favour of SOCK_DGRAM
Date: Wed, 14 May 2008 15:45:18 +0100
Message-ID: <20080514144518.GA30578@gerrit.erg.abdn.ac.uk>
References: <20080513093718.GA24185@gerrit.erg.abdn.ac.uk> <20080513162325.GF15306@ghostprotocols.net> <20080513170325.GB11499@gerrit.erg.abdn.ac.uk> <200805132037.39580.rdenis@simphalempin.com> <4829E87F.1070006@redhat.com> <20080514080942.GB4462@gerrit.erg.abdn.ac.uk> <482AF1DB.1060608@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: R?mi Denis-Courmont <rdenis@simphalempin.com>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	David Stevens <dlstevens@us.ibm.com>,
	David Miller <davem@davemloft.net>, dccp@vger.kernel.org,
	netdev@vger.kernel.org
To: Ulrich Drepper <drepper@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:53983 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757356AbYENOqA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2008 10:46:00 -0400
Content-Disposition: inline
In-Reply-To: <482AF1DB.1060608@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Ulrich Drepper:
| -----BEGIN PGP SIGNED MESSAGE-----
| Hash: SHA1
| 
| Gerrit Renker wrote:
| > RFC 3493 says that 0 for socktype/protocol means that caller will accept
| > any socket type / protocol, so presumably this does include DCCP and UDP-Lite.
| 
| I know what the RFC says.  But there are a gazillion of protocols out
| there and I won't create a record for all of them in case socktype and
| protocol are zero.  That's just overkill in 99.9% of all cases.
| 
| I assumption is that UDPlite is just too specialized to be useful to a
| wide array of people.  Yes, it case be supported if explicitly requested
| but should be returned if 0/0 is passed in.
| 
Sorry I misunderstood your email. Yes the above case is clear: if
someone supplies 0/0, s/he will probably not want any specialised
protocols in the return list.

This didn't appear in Remi's list. I have completed the list and put the
cases in the table below; `defaults' is interpreted in the way above.

 +--------------+---------------+---------------+---------------+
 | ai_socktype	| ai_protocol	| Return type	| Return Proto  |
 +--------------+---------------+---------------+---------------+
 | SOCK_DCCP	| IPPROTO_DCCP	| SOCK_DCCP	| IPPROTO_DCCP 	|
 | SOCK_DCCP	| 0		| SOCK_DCCP	| IPPROTO_DCCP 	|
 | 0		| IPPROTO_DCCP	| SOCK_DCCP	| IPPROTO_DCCP	|
 | 0		| 0		| (defaults)	| (defaults)	|
 +--------------+---------------+---------------+---------------+


If at all possible, for UDP-Lite it is similar. Since UDP-Lite is
actually just a form of UDP, this seems much less urgent than DCCP -
one might argue that UDP-Lite falls under SOCK_DGRAM/UDP.

 +-------------+-----------------+-------------+-----------------+
 | ai_socktype | ai_protocol	 | Return type |  Return Proto   |
 +-------------+-----------------+-------------+-----------------+
 | SOCK_DGRAM  | IPPROTO_UDPLITE | SOCK_DGRAM  | IPPROTO_UDPLITE |
 | SOCK_DGRAM  | 0		 | SOCK_DGRAM  | IPPROTO_UDP	 |
 | 0	       | IPPROTO_UDPLITE | SOCK_DGRAM  | IPPROTO_UDPLITE |   
 | 0	       | 0		 | (defaults)  | (defaults)      |
 +-------------+-----------------+-------------+-----------------+

... but it would still be good to have. 
