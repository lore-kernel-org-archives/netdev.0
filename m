From: Pawel Foremski <pjf@asn.pl>
Subject: Re: [RFC] Ethernet Cheap Cryptography
Date: Fri, 20 Oct 2006 22:18:49 +0200
Message-ID: <ehbava$iia$1@sea.gmane.org>
References: <200610151820.22867.dpc@asn.pl> <17717.40394.531846.695392@localhost.localdomain> <200610181115.12471.dpc@asn.pl> <17718.63424.509719.492216@localhost.localdomain> <eh87aq$71t$1@sea.gmane.org> <17720.12801.843076.819750@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7Bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:47837 "EHLO ciao.gmane.org")
	by vger.kernel.org with ESMTP id S1422980AbWJTUTN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2006 16:19:13 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1Gb0pe-0006P7-4n
	for netdev@vger.kernel.org; Fri, 20 Oct 2006 22:19:06 +0200
Received: from demiurg.asn.pl ([85.14.84.18])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 20 Oct 2006 22:19:06 +0200
Received: from pjf by demiurg.asn.pl with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 20 Oct 2006 22:19:06 +0200
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen J. Bevan wrote:

> Pawel Foremski writes:
>  > Secondly, IPsec won't decrease MSS in TCP encapsulated in PPPoE
>  > traffic, for example.
> 
> Various, commercial, IPsec products decrease the MSS for TCP
> encapsulated in PPPoE.  I've not checked the Linux 2.6 IPsec code to
> see if it does or if it can easily be made to.

Consider such an example: our task is to bridge two LANs managed by a
third-party ISP over a wireless link, with the highest performance possible
for such medium. The ISP has its clients on one LAN and a PPPoE
concentrator on the second one. Because the ISP doesn't trust us or is not
aware of our bridge, it uses MPPE to secure PPP. We cannot enforce any
changes to the way the ISP provides services to its end users.

In ASCII art, that would be:

[PPPoE server]---[Linux#1]--ccrypt--[dumb WiFi bridge] )))  \/
                                                            ||
[PPPoE client]---[Linux#2]--ccrypt--[dumb WiFi bridge] ((( <=/

Obviously, the dumb WiFi bridge cannot speak anything other than 1500-byte,
plain (not encrypted) Ethernet.

IMHO it's quite probable to come up with another example.

>  > Only if the rekeying traffic is the only being transmitted. IMHO a
>  > border case.
> 
> Unless you mask the size of your (re-)keying traffic by randomly
> padding the packets then they can be detected even in the middle of
> other traffic.

Yeah, you're right, forgot about padding.
 
>  > Sure, but that's IMHO little bit off-topic in regard to ccrypt, which
>  > is just an encryption back-end (eventually the rekeying daemon will sit
>  > in the userspace).
> 
> Sure.  However, there has to be a user<->kernel API and the question
> is whether what you have now is sufficient when a daemon is added or
> whether it will need to change?  If it does need to change it will
> need to be backwards compatible or need to be a separate API?

Ah, so you were asking about API. Then, Dawid should probably answer that
question as he's implemented the whole ccrypt. The sysfs API may not always
be available for userspace tools, good point.
 
> Also at least for IPsec, the kernel knows something about IKE in that
> generally IKE traffic is not encrypted by IPsec.  Instead IKE has its
> own encryption which it bootstraps using
> shared-secrets/certificates/public&preivate key pairs.  In the case of
> ccrypt either the ccryptKE protocol would need to bypass ccrypt or you
> need to way to start off with known keys, but not the same keys every
> time or that can be exploited.

I think in case of ccrypt it could be administrators task to ensure that the
ccrypt key exchange traffic won't be encrypted by it. Dawid mentioned using
vlans or macvlans, but I guess it wouldn't be much complicated to add
another possibilities in future, if required.

P.S. Please excuse me not CCing this post to all interested people, but
temporarily I'm using gmane gateway through knode (real pain ... ;-)

-- 
Pawel Foremski
pjf@asn.pl

