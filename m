From: Arnd Hannemann <hannemann@nets.rwth-aachen.de>
Subject: Re: [PATCH 2/3] net: TCP thin linear timeouts
Date: Thu, 29 Oct 2009 17:11:52 +0100
Message-ID: <4AE9BEC8.6020108@nets.rwth-aachen.de>
References: <4AE72079.4030504@simula.no> <4AE7262B.1060703@gmail.com>
 <4AE83FE4.1050309@nets.rwth-aachen.de>
 <07CD1135-C68B-4264-8CD3-C4BC0400FDA2@simula.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7BIT
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"ilpo.jarvinen@helsinki.fi" <ilpo.jarvinen@helsinki.fi>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Andreas Petlund <apetlund@simula.no>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753902AbZJ2QMK@vger.kernel.org>
In-reply-to: <07CD1135-C68B-4264-8CD3-C4BC0400FDA2@simula.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andreas Petlund schrieb:
> We have found no noticeable degradation of the goodput in a series of
> experiments we have performed in order to map the effects of the
> modifications. Furthermore, the modifications implemented in the patches
> are explicitly enabled only for applications where the developer knows
> that streams will be thin, thus only a small subset of the streams will
> apply the modifications.  
> 
> Graphs presenting results from experiments performed to analyse latency
> and fairness issues can be found here:
> http://folk.uio.no/apetlund/lktmp/

How often did you hit consecutive RTOs in these measurements?
As I see you did a measurement with 512 thick vs. 512 thin streams.
Lets do a hypothetical calculation with only 512 "thin" streams.
Lets further assume the rtt is low, so that RTO is around 200ms.
Assume each segment has 128 Bytes (already very small...).
Assume after a period of normal operation all streams are in
timeout-based loss recovery. (e.g. because destination endpoint
suddenly behaves like a black hole)
As all streams are in timeout-based loss recovery, each stream
will transmit 5 segments each second with your modification.
This would result in a throughput around 512*5*1024bit = 2560 kbit/s
and a goodput of 0 kbit/s (because the receiver is a black hole).
So you can easily saturate a 2 MBit/s link, only with retransmissions.

Unfortunately in Germany an ADSL uplink of 786 kbit/s is still quite
common, and its already called "broadband"...

Regarding the "small subset", why have a global sysctl option, then?
And I think "tcp_stream_is_thin(tp)" will be true for every flow
in the RTO case, at least for consecutive RTOs.

Best regards,
Arnd Hannemann
