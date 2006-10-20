From: Dawid Ciezarkiewicz <dpc@asn.pl>
Subject: Re: [RFC] Ethernet Cheap Cryptography
Date: Fri, 20 Oct 2006 21:50:00 +0200
Message-ID: <200610202150.00999.dpc@asn.pl>
References: <200610151820.22867.dpc@asn.pl> <200610181115.12471.dpc@asn.pl> <17718.63424.509719.492216@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from apollo.asn.pl ([85.14.104.1]:32644 "HELO apollo.asn.pl")
	by vger.kernel.org with SMTP id S2992708AbWJTTuH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2006 15:50:07 -0400
To: "Stephen J. Bevan" <stephen@dino.dnsalias.com>
In-Reply-To: <17718.63424.509719.492216@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday, 19 October 2006 05:57, Stephen J. Bevan wrote:
> And if the packets come out of order i.e. you get a packet with a new
> key followed by a packet with the old key?

As IV from invalid frames are saved ccrypt will synchronize anyway, but I was 
wrong in one aspect - in current implementation each reorder will cost two 
frames, not one. This could be possibly reduced to only one, but I must find 
a time to investigate that more.


> If the keying is done manually an attacker won't know when the keys
> are changed.  However, if keying is coordinated over the same link via
> a protocol (as is done with IKE for IPsec) then the attacker can see
> (or at least guess) the packets carrying the keying protcol thus know
> re-keying is going to occur.

Simple random delay should do the trick.

 
> For completness there are also switches that :-
> 
> * take notice of the TOS/DiffServ bits in an IP header and will
>   re-order based on them 

Looks like a good reason to change frame type field so it does not look like 
IP packet.


> * will re-order frames due to redundancy, load-balancing,
>   spanning-tree changes ... etc.

In summary - using ccrypt with switches may lead to problems.

