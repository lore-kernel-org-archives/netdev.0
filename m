From: Arnd Hannemann <hannemann@nets.rwth-aachen.de>
Subject: Re: [PATCH 1/3] net: TCP thin-stream detection
Date: Fri, 30 Oct 2009 16:24:02 +0100
Message-ID: <4AEB0512.4010804@nets.rwth-aachen.de>
References: <f7b4caf3a5b5c906cb8d508239455322.squirrel@webmail.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7BIT
Cc: William Allen Simpson <william.allen.simpson@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"ilpo.jarvinen@helsinki.fi" <ilpo.jarvinen@helsinki.fi>,
	"davem@davemloft.net" <davem@davemloft.net>
To: "apetlund@simula.no" <apetlund@simula.no>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932436AbZJ3PYS@vger.kernel.org>
In-reply-to: <f7b4caf3a5b5c906cb8d508239455322.squirrel@webmail.uio.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

apetlund@simula.no schrieb:
> As Ilpo writes, the mechanism we propose is simpler than the ID, and
> slightly more aggressive. The reason why we chose this is as follows: 1)
> The ID and Limited Transmit tries to prevent retransmission timeouts by
> retransmitting more aggressively, thus keeping the congestion window open
> even though congestion may be the limiting factor. If their limiting
> conditions change, they still have higher sending rates available. The
> thin-stream applications are not limited by congestion control. There is
> therefore no motivation to prevent retransmission timeouts in order to
> keep the congestion window open because in the thin-stream scenario, a
> larger window is not needed, but we retransmit early only to reduce
> application-layer latencies. 2) Our suggested implementation is simpler.
> 3) I believe that the reason why the ID has not been implemented in Linux
> is that the motivation did not justify the achieved result. We have
> analysed a wide range of time-dependent applications and found that they
> very often produce thin streams due to transmissions being triggered by
> human interaction. This changes the motivational picture since a thin
> stream is an indicator of time-dependency.


Both mechanism prevent retransmission timeouts, thereby reducing latency.
Who cares, that they were motivated by performance?

I agree, that you are more aggressive, and that your scheme may have
latency advantages, at least for the Limited Transmit case. And there are
probably good reasons for your proposal. But I really think you should
bring your proposal up in IETF TCPM WG. I have the feeling that there are
a lot of corner cases we didn't think of.

One example: Consider standard NewReno non-SACK enabled flow:
For some reasons two data packets get reordered.
The TCP sender will produce a dupACK and an ACK.
The dupACK will trigger (because of your logic) a spurious retransmit.
The spurious retransmit will trigger a dupACK.
This dupACK will again trigger a spurious retransmit.
And this game will continue, unless a packet is dropped by coincidence.

P.S.: The Early-Rexmit ID has not been implemented in Linux,
because our student who was working on that is busy with something
else...

Best regards,
Arnd Hannemann
