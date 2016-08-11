From: Andreas Werner <andreas.werner@men.de>
Subject: Re: [PATCH RESEND] net: can: Introduce MEN 16Z192-00 CAN controller
 driver
Date: Thu, 11 Aug 2016 09:14:59 +0200
Message-ID: <20160811071458.GA25813@awelinux>
References: <20160726091555.GA26227@awelinux>
 <9487fe77-dbd0-3a64-b648-cf76b897feda@grandegger.com>
 <20160808113938.GA17459@awelinux>
 <456c4f82-6a53-e821-3396-63d413db9eb7@grandegger.com>
 <20160808140546.GA1733@awelinux>
 <808e919b-8643-2113-9fde-001861883abe@grandegger.com>
 <20160809061038.GC1733@awelinux>
 <a0169f54-c8c7-5cf6-b93b-acd4a308a052@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andreas Werner <andreas.werner@men.de>,
	Wolfgang Grandegger <wg@grandegger.com>, <mkl@pengutronix.de>,
	<linux-can@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <davem@davemloft.net>,
	<jthumshirn@suse.de>, <andy@wernerandy.de>,
	<michael.miehling@men.de>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <a0169f54-c8c7-5cf6-b93b-acd4a308a052@hartkopp.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 10, 2016 at 10:28:45PM +0200, Oliver Hartkopp wrote:
> Hi Andreas,
> 
> On 08/09/2016 08:10 AM, Andreas Werner wrote:
> >On Mon, Aug 08, 2016 at 04:35:34PM +0200, Wolfgang Grandegger wrote:
> 
> >>>>>>You specify here one echo_skb but it's not used anywhere. Local loopback
> >>>>>>seems not to be implemented.
> >>>>>>
> >>>>>
> >>>>>Agree with you, will set it to "0".
> >>>>
> >>>>No, the local loopback is mandetory!
> >>>>
> >>>
> >>>Hm ok, but if i check alloc_candev() in drivers/net/can/dev.c
> >>>it is not mandatory.
> 
> It is.
> 
> Even those drivers that show up to use zero echo skbs in alloc_candev()
> implement the echo functionality correct.
> 
> Just check 'git grep IFF_ECHO'. Even grcan.c and janz-ican3.c have IFF_ECHO
> set - but implement it in a different way without using the provided
> machanism from dev.c .
> 

Ok I am with you.

> >>>In the Documentation/networking/can.txt
> >>>there is also a "should" and a fallback mechnism if the driver
> >>>does not support the local loopback.
> 
> But this fallback mechanism is bad - really bad!
> 
> E.g. the slcan.c driver sends a stream of CAN frames without knowing whether
> the frames ever hit the wire. The slcan driver is more less for hobby users.
> The CAN frame echo with IFF_ECHO gives a correct representation of the
> traffic on the wire - including the correct timestamps.
> 
> You really want to know whether a CAN frame was sent correctly on the bus
> instead of getting some shortcut info from inside the network layer.
> .

Thanks for the explanation. I make it more clear why its mandatory.

> >>
> >>Well, s/driver/hardware/ ! Local loopback is the preferred mechanism.
> >>
> >
> >Sure...
> >
> >>>I'm currently ok with this fallback mechanism.
> 
> /me not.
> 
> >>>Anyway I am not sure that the driver can handle the echo skb correctly.
> >>>If i understand it correctly, the can_get_echo_skb() is normally called
> >>>on a "TX done IRQ" to get the skb and loop it back.
> 
> ack.
> 
> >>>I do not have such a "TX done IRQ" and have not implemented implemented
> >>>and added the local looback.
> 
> I'm not really sure how grcan.c and janz-ican3.c implemented the echo
> functionality but they must have faced a similar situation.
> 

I will check those driver to get more information about the implementation.

> A local loopback inside the CAN controller which is generated after
> successful transmit is an excellent implementation with excellent
> timestamps. The only problem for you is to detect the looped CAN frames and
> match them to the skb pointer of the outgoing frame to 'receive' the correct
> echo skb.
> 

At the moment, i think there is no way to detect those looped frames.
I will talk to our IC designer and discuss this issue with him. Maybe we
have the possibility to get a local loopback inside the CAN controller.
This seems to be the best way to do it.

> When you send CAN frames to an unconnected CAN bus it can't be sent out due
> to the missing acknowledge from other nodes. So when you send frames and you
> get echo frames due to the fallback mode your cool CAN controller degrades
> to slcan level.
> 

I agree with you. This is what we do not want to have.

> Regards,
> Oliver
> 
> ps. Do you have any URL where one can get the MEN 16Z192 spec?

No sorry, its not available.


Regards
Andy
