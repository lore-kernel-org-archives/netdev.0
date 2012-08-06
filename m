From: Olivier Sobrie <olivier@sobrie.be>
Subject: Re: [PATCH] can: kvaser_usb: Add support for Kvaser CAN/USB devices
Date: Mon, 6 Aug 2012 07:27:27 +0200
Message-ID: <20120806052727.GA16630@hposo>
References: <1343626352-24760-1-git-send-email-olivier@sobrie.be>
 <50166BF2.9000700@pengutronix.de>
 <20120730133323.GA13941@hposo>
 <5017ABC6.7030307@pengutronix.de>
 <20120731130650.GA23541@hposo>
 <5017DD5B.2030701@pengutronix.de>
 <20120802105358.GA23787@hposo>
 <501A6AE7.9060508@pengutronix.de>
 <501EDB0B.5040204@grandegger.com>
Reply-To: Olivier Sobrie <olivier@sobrie.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marc Kleine-Budde <mkl@pengutronix.de>, linux-can@vger.kernel.org,
	netdev@vger.kernel.org
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <501EDB0B.5040204@grandegger.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 05, 2012 at 10:43:55PM +0200, Wolfgang Grandegger wrote:
> On 08/02/2012 01:56 PM, Marc Kleine-Budde wrote:
> > On 08/02/2012 12:53 PM, Olivier Sobrie wrote:
> ...
> >> I actually implemeted it as you said and here is what I observed in
> >> candump output with restart_ms set to 100 ms:
> >>
> >> t0: Short circuit between CAN-H and CAN-L + cansend can1 123#1122
> >>   can1  2000008C  [8] 00 04 90 00 00 00 00 00   ERRORFRAME
> >> 	controller-problem{rx-error-warning}
> >> 	protocol-violation{{tx-recessive-bit-error,error-on-tx}{}}
> >> 	bus-error
> >>   can1  2000008C  [8] 00 10 90 00 00 00 00 00   ERRORFRAME
> >> 	controller-problem{rx-error-passive}
> >> 	protocol-violation{{tx-recessive-bit-error,error-on-tx}{}}
> >> 	bus-error
> >>   can1  200000C8  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
> >> 	protocol-violation{{tx-recessive-bit-error,error-on-tx}{}}
> >> 	bus-off
> >> 	bus-error
> >> ...
> 
> FYI, the option "-td" nicely shows the timing. I assume that the
> "warning->passive->bus-off" sequence repeats because automatic bus-off
> is active via ip option "restart-ms xx ms". What I'm missing is the
> message "restarted-after-bus-off". Maybe it's not listed here...

Indeed it's missing. Please look at the patch I just sent if it is now
correct or not.

> 
> >>   can1  2000008C  [8] 00 04 90 00 00 00 00 00   ERRORFRAME
> >> 	controller-problem{rx-error-warning}
> >> 	protocol-violation{{tx-recessive-bit-error,error-on-tx}{}}
> >> 	bus-error
> >>   can1  2000008C  [8] 00 10 90 00 00 00 00 00   ERRORFRAME
> >> 	controller-problem{rx-error-passive}
> >> 	protocol-violation{{tx-recessive-bit-error,error-on-tx}{}}
> >> 	bus-error
> >>   can1  200000C8  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
> >> 	protocol-violation{{tx-recessive-bit-error,error-on-tx}{}}
> >> 	bus-off
> >> 	bus-error
> >>
> >> t1: short circuit removed
> >>   can1  123  [2] 11 22
> >>   can1  20000100  [8] 00 00 00 00 00 00 00 00   ERRORFRAME
> >> 	restarted-after-bus-of
> >>
> >> The echo coming before the restart looks weird? No?
> 
> Yes. It should come later.

Ok I've to change this.

> 
> >> Shouldn't we drop the frame once BUF-OFF is reached?
> 
> No.

Ok.

> 
> > No, I don't think so. But wait for Wolfgang, here's more into error
> > handling then me.
> 
> Looking to your code it's not clear to me how you do recovery from
> bus-off (called "restart"). This is usually done via
> do_set_mode(CAN_MODE_START), either manually (restart-ms==0) or
> automatically (restart-ms>0). Could you please explain how the device
> does bus-off recovery? Does the hardware do it automatically? This
> should be suppressed if if restart-ms==0 (as Marc already pointed out).

The hardware automatically recovers from BUS-OFF if it isn't stopped.
In the second version of the patch I just sent, I put the device off if
restart-ms == 0.

Thanks,

-- 
Olivier
