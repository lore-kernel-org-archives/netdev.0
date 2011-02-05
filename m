From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH] tcp: Increase the initial congestion window to 10.
Date: Sat, 5 Feb 2011 14:58:42 +0100
Message-ID: <20110205135842.GB4752@gerrit.erg.abdn.ac.uk>
References: <20110202.170750.229739784.davem@davemloft.net> <AANLkTi=z-1-=R4X6hxs738jMEdYwfMPBFq9Ss-JwKCy3@mail.gmail.com> <AANLkTimuYxHd5AtGSB2+wg2JE7LEKPjGssoQZuOWYrw-@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, dccp@vger.kernel.org
To: Leandro Melo de Sales <leandroal@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:64876 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751746Ab1BEN6t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Feb 2011 08:58:49 -0500
Content-Disposition: inline
In-Reply-To: <AANLkTimuYxHd5AtGSB2+wg2JE7LEKPjGssoQZuOWYrw-@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Leandro,
| >  include/net/tcp.h      |   12 +++---------
| >  net/dccp/ccids/ccid2.c |    9 +++++++++
|
David's change only affects CCID-2, CCID-3/4 remain unaffected,
they use rfc3390_initial_rate() (which does almost the same).
 
|     I don't think this change will make sense for DCCP, once IW10 is
| for the cases of short-lived flows. DCCP is used on scenarios for
| multimedia flows, which are, in general, long-lived flows. So, IMO the
| way how we calculate IW for DCCP is appropriate, at least considering
| a quick answer. 
I agree with you, and also vote to eventually bring CCID-2 on a par with
the state of art in TCP. Before we can do this, the CCID-2 implementation
needs some work (as per separate thread with Samuel Jero).

| In fact, nowadays we need better congestion control algorithms for DCCP,
| and in this sense we are working on adapt TCP Cubic for DCCP as a CCID,
| and also we started some work to make DCCP support TCP pluggable
| mechanism , which will allow us to use TCP congestion control
| algorithms in DCCP.
This is very good news and am very much looking forward to the new approach.


| DCCP should calculate its IW as specified in RFC3390 rather than set
| it to IW10. For the moment, I understand that for DCCP, we have to 
| discuss more about this in a separated thread.
Agree that we should keep an eye on this - perhaps too early to turn it into a
should. Networking speeds are growing, and many of the simulations were based
on TCP Reno which stems from the 10 Mbit ethernet era.
