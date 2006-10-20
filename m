From: stephen@dino.dnsalias.com (Stephen J. Bevan)
Subject: Re: [RFC] Ethernet Cheap Cryptography
Date: Thu, 19 Oct 2006 19:18:41 -0700
Message-ID: <17720.12801.843076.819750@localhost.localdomain>
References: <200610151820.22867.dpc@asn.pl>
	<17717.40394.531846.695392@localhost.localdomain>
	<200610181115.12471.dpc@asn.pl>
	<17718.63424.509719.492216@localhost.localdomain>
	<eh87aq$71t$1@sea.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from S010600014e000000.vc.shawcable.net ([70.79.40.36]:62815 "EHLO
	dino.dnsalias.com") by vger.kernel.org with ESMTP id S1946828AbWJTCTp
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Oct 2006 22:19:45 -0400
To: Pawel Foremski <pjf@asn.pl>
In-Reply-To: <eh87aq$71t$1@sea.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pawel Foremski writes:
 > First, ccrypts task is to secure Ethernet, not IP.

Understood, but the vast majority of traffic running over Ethernet
that a user cares about is IP and so IPsec does the job.  Obviously
IPsec cannot handle non-IP traffic but the question is what non-IP
traffic do users want encrypted?


 > Secondly, IPsec won't decrease MSS in TCP encapsulated in PPPoE
 > traffic, for example. 

Various, commercial, IPsec products decrease the MSS for TCP
encapsulated in PPPoE.  I've not checked the Linux 2.6 IPsec code to
see if it does or if it can easily be made to.


 > > b) what traffic other than IP traffic needs to be encrypted.
 > 
 > PPPoE; Ethernet in general.

PPPoE carrying IP can be handled by IPsec as noted above.  That leaves
Ethernet in general.


 > > If the keying is done manually an attacker won't know when the keys
 > > are changed.  However, if keying is coordinated over the same link via
 > > a protocol (as is done with IKE for IPsec) then the attacker can see
 > > (or at least guess) the packets carrying the keying protcol thus know
 > > re-keying is going to occur.
 > 
 > Only if the rekeying traffic is the only being transmitted. IMHO a border
 > case.

Unless you mask the size of your (re-)keying traffic by randomly
padding the packets then they can be detected even in the middle of
other traffic.


 > > Indeed, in IPsec, the equivalent of ccrypt is ESP and that's rather
 > > straighforward.  The complicated part is IKE, the userspace component
 > > that handles keying.  It is certainly possible to create something
 > > simpler than IKE (e.g. IKEv2 is somewhat simpler) but the devil is in
 > > the details.
 > 
 > Sure, but that's IMHO little bit off-topic in regard to ccrypt, which is
 > just an encryption back-end (eventually the rekeying daemon will sit in the
 > userspace).

Sure.  However, there has to be a user<->kernel API and the question
is whether what you have now is sufficient when a daemon is added or
whether it will need to change?  If it does need to change it will
need to be backwards compatible or need to be a separate API?

Also at least for IPsec, the kernel knows something about IKE in that
generally IKE traffic is not encrypted by IPsec.  Instead IKE has its
own encryption which it bootstraps using
shared-secrets/certificates/public&preivate key pairs.  In the case of
ccrypt either the ccryptKE protocol would need to bypass ccrypt or you
need to way to start off with known keys, but not the same keys every
time or that can be exploited.
