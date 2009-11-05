From: Andreas Petlund <apetlund@simula.no>
Subject: Re: [PATCH 1/3] net: TCP thin-stream detection
Date: Thu, 05 Nov 2009 14:34:55 +0100
Message-ID: <4AF2D47F.4030701@simula.no>
References: <f7b4caf3a5b5c906cb8d508239455322.squirrel@webmail.uio.no> <4AEB0512.4010804@nets.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: William Allen Simpson <william.allen.simpson@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"ilpo.jarvinen@helsinki.fi" <ilpo.jarvinen@helsinki.fi>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Arnd Hannemann <hannemann@nets.rwth-aachen.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756424AbZKENe4@vger.kernel.org>
In-Reply-To: <4AEB0512.4010804@nets.rwth-aachen.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnd Hannemann wrote:
> Both mechanism prevent retransmission timeouts, thereby reducing latency.
> Who cares, that they were motivated by performance?

The essence of motivation is that there exist an incentive for performing an 
action. If the motivation for fast retransmitting earlier is to keep the cwnd 
open for a greedy application with small time-dependency, the question may be 
posed whether it is worth the effort of the proposed changes. With the 
thin-stream applications, we have confirmed that this is very often an 
indication of time-dependent/interactive applications (like SSH-text sessions, 
RDP, sensor networks, stock trading systems, interactive games etc). We have 
further shown that such applications are prone to lag upon retransmissions due 
to the inadequacies of TCP to deal with thin streams. We have also shown that 
by performing the proposed adjustments, we can drastically improve the 
situation. 

Since we now know that the modifications can drastically improve the user 
experience, the motivation/incentive for implementing the modifications is 
increased. 

> I agree, that you are more aggressive, and that your scheme may have
> latency advantages, at least for the Limited Transmit case. And there are
> probably good reasons for your proposal. But I really think you should
> bring your proposal up in IETF TCPM WG. I have the feeling that there are
> a lot of corner cases we didn't think of.
> 
> One example: Consider standard NewReno non-SACK enabled flow:
> For some reasons two data packets get reordered.
> The TCP sender will produce a dupACK and an ACK.
> The dupACK will trigger (because of your logic) a spurious retransmit.
> The spurious retransmit will trigger a dupACK.
> This dupACK will again trigger a spurious retransmit.
> And this game will continue, unless a packet is dropped by coincidence.

Such an effect will be extremely rare. It will depend on the application 
producing an extremely even flow of packets with just the right 
interarrival time, and also on reordering of data (which also will 
happen very seldom when the number of packets in flight are so low). 
Even though it can happen, the data flow will progress (with spurious 
retransmissions). The effect will stop as soon as the application sends 
more than 4 segments in an RTT (which will disable the thin-stream 
modifications) or less than 1 (which will cause all segments to be 
successfully ACKed), or if, as you say, a packet is dropped.

I will be thankful for more input on eventual corner cases and also on 
test cases that we may perform to evaluate the modifications for 
scenarios that are of concern.

Best regards,
Andreas
