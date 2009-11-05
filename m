From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 1/3] net: TCP thin-stream detection
Date: Thu, 5 Nov 2009 15:45:56 +0200 (EET)
Message-ID: <alpine.DEB.2.00.0911051536200.7024@wel-95.cs.helsinki.fi>
References: <f7b4caf3a5b5c906cb8d508239455322.squirrel@webmail.uio.no> <4AEB0512.4010804@nets.rwth-aachen.de> <4AF2D47F.4030701@simula.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Arnd Hannemann <hannemann@nets.rwth-aachen.de>,
	William Allen Simpson <william.allen.simpson@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Andreas Petlund <apetlund@simula.no>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756551AbZKENp5@vger.kernel.org>
In-Reply-To: <4AF2D47F.4030701@simula.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 5 Nov 2009, Andreas Petlund wrote:

> Arnd Hannemann wrote:
> > 
> > One example: Consider standard NewReno non-SACK enabled flow:
> > For some reasons two data packets get reordered.
> > The TCP sender will produce a dupACK and an ACK.
> > The dupACK will trigger (because of your logic) a spurious retransmit.
> > The spurious retransmit will trigger a dupACK.
> > This dupACK will again trigger a spurious retransmit.
> > And this game will continue, unless a packet is dropped by coincidence.
> 
> Such an effect will be extremely rare. It will depend on the application 
> producing an extremely even flow of packets with just the right 
> interarrival time, and also on reordering of data (which also will 
> happen very seldom when the number of packets in flight are so low). 
> Even though it can happen, the data flow will progress (with spurious 
> retransmissions). The effect will stop as soon as the application sends 
> more than 4 segments in an RTT (which will disable the thin-stream 
> modifications) or less than 1 (which will cause all segments to be 
> successfully ACKed), or if, as you say, a packet is dropped.

I'd simply workaround this problem by requiring SACK to be enabled for 
such a connection. This is reinforced by the fact that small windowed 
transfers want it certainly to be on anyway to get the best out of ACK 
flow even if there were some ACK losses.


-- 
 i.
