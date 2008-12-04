From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: TCP default congestion control in linux should be newreno
Date: Thu, 4 Dec 2008 23:05:29 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0812042250360.27758@wrl-59.cs.helsinki.fi>
References: <b98e548c0812030812i3980791y2e4135cb9c5110c0@mail.gmail.com>
 <Pine.LNX.4.64.0812041419500.26947@wrl-59.cs.helsinki.fi>
 <20081204185022.6108d19e@gmail.com>  <20081204.101805.45306327.davem@davemloft.net>
 <b98e548c0812041105o6c2ded8br3c2349cabceaf99f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, ldecicco@gmail.com,
	Netdev <netdev@vger.kernel.org>
To: Saverio Mascolo <saverio.mascolo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:39423 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752600AbYLDVFb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2008 16:05:31 -0500
In-Reply-To: <b98e548c0812041105o6c2ded8br3c2349cabceaf99f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 4 Dec 2008, Saverio Mascolo wrote:

> we have done many experiments, along with many other "researcher" as u
> say. as a consequence, i have maturated the belief that changing the
> probing phase of the van jacobson TCP, which is linear, could not be
> not a wise thing .
>  the rationale of  VJ choice seems simple to me: if  the window is
> increased of one packet in one rtt, i can drop at most one packet in
> one rtt and so i have to recover only one packet in one rtt (note that
> rtt is the feedback reaction  time). If cwnd is increased of N packets
> i could drop N packets and i could need to recover N pkts. this is the
> problem here.

1) N drops is not as bad as you seem to imply, sadly this is a very common 
misconcept among much tcp related research that fast retransmits and the
following recovery are a bad things in itself. SACK handles it very 
efficiently as long as N is considerably less than cwnd and the buffer 
before the bottleneck was adequate to keep the link fully utilized over 
that recovery rtt. Thus the first claim (vj one) does not follow from the 
latter on (n pkts is bad), it is bogus reasoning.

2) The main benefit of maintaining VJ's one packet increment is the better 
interflow fairness on short time scale which again is a tradeoff.

>   window dynamics of  newreno cwnd behave  better, they are smoother.
> others cwnd seem chaotic.

"seem chaotic" (to humans) != chaotic btw. E.g., any rapid change may 
seem chaotic. Also utms buffers might "seem chaotic" btw :-) which 
makes your equation even more complex one (this is not a joke, I've 
actually probed its behavior a bit).


-- 
 i.
