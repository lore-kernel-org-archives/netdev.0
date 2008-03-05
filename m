From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: TCP IPv4 strange retransmits
Date: Wed, 5 Mar 2008 21:32:27 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0803052124570.11034@kivilampi-30.cs.helsinki.fi>
References: <47CD4808.1050202@nets.rwth-aachen.de>
 <Pine.LNX.4.64.0803041507001.5423@kivilampi-30.cs.helsinki.fi>
 <47CD5D43.9020408@nets.rwth-aachen.de> <Pine.LNX.4.64.0803042243050.15040@kivilampi-30.cs.helsinki.fi>
 <47CDD543.1090607@nets.rwth-aachen.de> <Pine.LNX.4.64.0803050819020.15712@kivilampi-30.cs.helsinki.fi>
 <47CE9A67.5010002@nets.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-2096636983-1204745547=:11034"
Cc: Netdev <netdev@vger.kernel.org>
To: Arnd Hannemann <hannemann@nets.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:46804 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751355AbYCETca (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2008 14:32:30 -0500
In-Reply-To: <47CE9A67.5010002@nets.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-2096636983-1204745547=:11034
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Wed, 5 Mar 2008, Arnd Hannemann wrote:

> Ilpo Järvinen wrote:
> > On Wed, 5 Mar 2008, Arnd Hannemann wrote:
> > 
> >> Ilpo Järvinen wrote:
> > 
> > ...
> > /* Heurestics to calculate number of duplicate ACKs. There's no dupACKs
> 
> Great :-) But shouldn't it read "heuristics" ?

Sure, a Finnish vovel leaked into it. If somebody would have asked,
I wouldn't even have known which was the right form in English.

> > Another thing you should consider is reordering detection which hopefully 
> > worked at 13:08:20.667529 through the newly discored SACK block which is 
> > _lower_ than the highestmost SACK block received so far. That results in 
> > FACK -> RFC3517, FACK is built on inorder assumptions and whenever we find 
> > that untrue, e.g., due to SACK/ACK for non-rexmit when something larger 
> > has been confirmed received we disable it. Ah, but this was 2.6.24.y? It 
> 
> Yes, it was 2.6.24.2. Actually you can see reordering detection at work here[3],
> the tool[4] we are using to measure TCP throughput samples the tcp_info struct and the
> column #reor should reflect tp->reordering.
> First it is 3 then it grows up to 16. Off course this is only a hint because
> tcp_info is only sampled every 50ms in this example, but at least it shows that some
> reordering detection took place...

Ok. I usually can determine exact events from tcpdump, too used to
them... :-)

> > doesn't yet do RFC3517 IIRC, but has something remotely resembling 
> > newreno, but only for the first packet because the next cumulative ACK may 
> > often trigger timedout loop which basically marks everything lost (I don't 
> > remember if the latter was changed to occur only with FACK ages ago or 
> > not).
> 
> Not sure if I understood this. Will have to look into this some more.

Before 2.6.25, the non-FACK SACK was quite strange mixture of things. 
It won't resemble anything RFCish by any means, unless timedout loop 
(see the loop that plays with scorboard_skb_hint) was already changed to 
be used with FACK only in 2.6.24 or before it (I don't remember if I ever 
submitted that because making non-FACK SACK behave very close to what 
RFC3517 does was just around the corner as well).


-- 
 i.
---696243703-2096636983-1204745547=:11034--
