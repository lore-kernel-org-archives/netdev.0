From: Kurt Van Dijck <kurt.van.dijck@eia.be>
Subject: Re: [Socketcan-users] poll broken (for can)
Date: Wed, 30 Mar 2011 09:46:23 +0200
Message-ID: <20110330074623.GB339@kurt.e-circ.dyndns.org>
References: <1301321142.9519.10.camel@lukonin-pc>
 <4D90A7E9.1080804@grandegger.com>
 <4D90AA8A.9010804@pengutronix.de>
 <4D90AF67.1080405@grandegger.com>
 <4D90B3B0.2010401@pengutronix.de>
 <4D90CB17.4030205@hartkopp.net>
 <4D90E262.1090201@pengutronix.de>
 <4D923B00.20500@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Marc Kleine-Budde <mkl@pengutronix.de>, Netdev@vger.kernel.org,
	socketcan-users@lists.berlios.de,
	Wolfgang Grandegger <wg@grandegger.com>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4D923B00.20500@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 29, 2011 at 10:03:12PM +0200, Oliver Hartkopp wrote:
> On 28.03.2011 21:32, Marc Kleine-Budde wrote:
> > On 03/28/2011 07:53 PM, Oliver Hartkopp wrote:
> >> On 28.03.2011 18:13, Marc Kleine-Budde wrote:
> >>> On 03/28/2011 05:55 PM, Wolfgang Grandegger wrote:

> > What do we really want to specify?
> 
> Hm - the problem could be that people expect their frames to be sent 'in
> time', so if we increase the tx_queue_len, it's not transparent when the
> frames are potentially leaving the system - and if the application data is
> already out-dated when hitting the medium.
> 
> What about having up to three CAN frames in each CAN_RAW socket send buffer
> and e.g.50 frames in the tx_queue_len of the netdevice as a starting point?
50 looks good, but 3 is a bit small IMHO.
> 
> 
> > 
> > Something like: queue up to X frames per socket and queue only Y frames
> > per device. Where Y = X * n and n is "I don't know yet"?
> > 
> > Y is simple, it's the tx_queue_len. But X is more complicated. The can
> > frames have non constant length (i.e. dlc) and I'm not sure that the
> > netdev people say if we misuse the sock_alloc_send_pskb() for our
> > tx-flow-control :)
> 
> I would propose to count the CAN frames independently from the can_dlc.
ack.
> AFAIK
> the tx_queue_len is dealing with skb's - and the skb->len for the socket send
> buffer is also size of struct can_frame, right?
ack.
> 
> Regards,
> Oliver
> 
> _______________________________________________
> Socketcan-users mailing list
> Socketcan-users@lists.berlios.de
> https://lists.berlios.de/mailman/listinfo/socketcan-users
