From: Pawel Foremski <pjf@asn.pl>
Subject: Re: [RFC] Ethernet Cheap Cryptography
Date: Thu, 19 Oct 2006 17:58:56 +0200
Message-ID: <eh87aq$71t$1@sea.gmane.org>
References: <200610151820.22867.dpc@asn.pl> <17717.40394.531846.695392@localhost.localdomain> <200610181115.12471.dpc@asn.pl> <17718.63424.509719.492216@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7Bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:51947 "EHLO ciao.gmane.org")
	by vger.kernel.org with ESMTP id S1946145AbWJSQDO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2006 12:03:14 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1GaaJl-0001Db-Bg
	for netdev@vger.kernel.org; Thu, 19 Oct 2006 18:00:25 +0200
Received: from gprs10.orange.pl ([217.116.100.240])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 19 Oct 2006 18:00:25 +0200
Received: from pjf by gprs10.orange.pl with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 19 Oct 2006 18:00:25 +0200
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen J. Bevan wrote:

> Dawid Ciezarkiewicz writes:
>  > It enforces to use upper level encryption with internal
>  > fragmentation which is problem because of more more frames that
>  > those bridges have to handle, bigger traffic etc.
> 
> Where did the fragmentation come from?  If you are sending TCP over
> IPsec then the ESP/AH code should decrease the TCP MSS as it goes
> through to take acount of the extra space that IPsec will take up.
> Thus neither end-point will ever send a frame on that session that
> will require fragmentation.  Granted you can still have a problem if
> someone sends a UDP packet that is close to the 1500 MTU, but RFCs
> recommend against it (e.g. DNS&SIP) and applications should try to
> avoid it.

First, ccrypts task is to secure Ethernet, not IP. Secondly, IPsec won't
decrease MSS in TCP encapsulated in PPPoE traffic, for example.

> Thus the argument for ccrypt should say :-
> 
> a) why IPsec is not suitable for securing IP traffic in WIFI scenarios.

It's suitable. But for IP.

> b) what traffic other than IP traffic needs to be encrypted.

PPPoE; Ethernet in general.

>  > This allows key switching without loosing any frames. It should be done
>  > quickly, since when in "key transition" state all invalid/spoofed
>  > frames have  double cpu impact on receiver. Shouldn't be a problem
>  > because attacker should have no clue about when key is being switched.
> 
> If the keying is done manually an attacker won't know when the keys
> are changed.  However, if keying is coordinated over the same link via
> a protocol (as is done with IKE for IPsec) then the attacker can see
> (or at least guess) the packets carrying the keying protcol thus know
> re-keying is going to occur.

Only if the rekeying traffic is the only being transmitted. IMHO a border
case.

> Indeed, in IPsec, the equivalent of ccrypt is ESP and that's rather
> straighforward.  The complicated part is IKE, the userspace component
> that handles keying.  It is certainly possible to create something
> simpler than IKE (e.g. IKEv2 is somewhat simpler) but the devil is in
> the details.

Sure, but that's IMHO little bit off-topic in regard to ccrypt, which is
just an encryption back-end (eventually the rekeying daemon will sit in the
userspace).

Oh, and of course I agree IKE (v1) is too complicated :-).

>  > I was not aware of that. Thanks. I will add this info to
>  > documentation. There is nothing actually I can do about that in the
>  > form that ccrypt is mean to be now.
> 
> For completness there are also switches that :-
> 
> * take notice of the TOS/DiffServ bits in an IP header and will
>   re-order based on them
> 
> * will re-order frames due to redundancy, load-balancing,
>   spanning-tree changes ... etc.

I'll only add to what Dawid has said that ccrypt has been designed for
direct P2P links, with single path (and no such switches on it's way).
Later it turned out to be applicable for eg. small (simple) LANs or
wireless ad-hoc networks.

Thanks for your remarks!

Bye,

-- 
Pawel Foremski  
pjf@asn.pl

