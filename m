From: "Ira W. Snyder" <iws-lulEs6mt1IksTUYHLfqkUA@public.gmane.org>
Subject: Re: [PATCH 2/3] can: add support for Janz VMOD-ICAN3 Intelligent
	CAN	module
Date: Mon, 22 Mar 2010 08:53:18 -0700
Message-ID: <20100322155318.GA19251@ovro.caltech.edu>
References: <> <1268930324-29841-3-git-send-email-iws@ovro.caltech.edu>
	<4BA33D5A.8070000@grandegger.com>
	<20100319151914.GB13672@ovro.caltech.edu>
	<4BA39C05.8050800@grandegger.com>
	<20100319200325.GE13672@ovro.caltech.edu>
	<4BA3DAF1.4090206@grandegger.com>
	<20100319215227.GF13672@ovro.caltech.edu>
	<4BA47F64.8030108@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4BA47F64.8030108-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Mar 20, 2010 at 08:55:16AM +0100, Wolfgang Grandegger wrote:
> Ira W. Snyder wrote:
> > On Fri, Mar 19, 2010 at 09:13:37PM +0100, Wolfgang Grandegger wrote:
> >> Ira W. Snyder wrote:
> >>> On Fri, Mar 19, 2010 at 04:45:09PM +0100, Wolfgang Grandegger wrote:
> >>>> Ira W. Snyder wrote:
> >>>>> On Fri, Mar 19, 2010 at 10:01:14AM +0100, Wolfgang Grandegger wrote:
> >>>>>> Hi Ira,
> >>>>>>
> >>>>>> we already discussed this patch on the SocketCAN mailing list and there
> >>>>>> are just a few minor issues and the request to add support for the new
> >>>>>> "berr-reporting" option, if feasible. See:
> >>>>>>
> >>>>>>   commit 52c793f24054f5dc30d228e37e0e19cc8313f086
> >>>>>>   Author: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
> >>>>>>   Date:   Mon Feb 22 22:21:17 2010 +0000
> >>>>>>
> >>>>>>     can: netlink support for bus-error reporting and counters
> >>>>>>     
> >>>>>>     This patch makes the bus-error reporting configurable and allows to
> >>>>>>     retrieve the CAN TX and RX bus error counters via netlink interface.
> >>>>>>     I have added support for the SJA1000. The TX and RX bus error counters
> >>>>>>     are also copied to the data fields 6..7 of error messages when state
> >>>>>>     changes are reported.
> >>>>>>
> >>>>>> Should not be a big deal.
> >>>>>>
> >>>>> I think this patch came along since my last post of the driver. I must
> >>>>> have missed it. I'll try and add support.
> >>>> No problem, it's really new. Just just need to enable BEI depending on
> >>>> CAN_CTRLMODE_BERR_REPORTING.
> >>>>
> >>> I have one final question about this.
> >>>
> >>> The documentation for the firmware isn't very specific here. I believe
> >>> that in order to get any kind of error messages, I need the bus error
> >>> feature turned on. What is the expected behavior of an SJA1000 with the
> >>> BEI (bus error interrupt) turned off? Will you still get warning
> >>> messages for ERROR_ACTIVE -> ERROR_PASSIVE state transitions?
> >> Yes. State transitions are enabled with EI and EPI.
> >>
> > 
> > I cannot set the registers directly, but I think I got it right. See
> > below.
> > 
> >>> I'm not sure how I would go about testing this feature, either. Ideas?
> >> Send messages without cable connected and watch the error messages with
> >> "candump any,0:0,#ffffffff". With "ip ... berr-reporting on" you should
> >> see additional bus-errors.
> >>
> > 
> > Ok, I tried this. On one controller, I turned on bus-error reporting. On
> > the other, I turn off bus-error reporting. I then tried sending lots of
> > messages with the cable unplugged. Here is what happened:
> > 
> > bus-error reporting on:
> > Lots of CAN_ERR_BUSERR messages are flooded in candump. There is also a
> > CAN_ERR_CRTL_TX_WARNING message, when there are too many TX errors.
> 
> OK, you will now also understand why bus-error reporting is off by
> default. On low-end systems bus-error flooding may even hang the system.
> 
> > bus-error reporting off:
> > There was only one message reported before the controller went into
> > ERROR-WARNING state. It was the same CAN_ERR_CRTL_TX_WARNING message as
> > above. There was no flooding of CAN_ERR_BUSERR messages.
> > 
> > Does this seem right? It seems pretty good to me.
> 
> Yes, I'm just missing an error-passive message. What state does "ip -d
> link show can0" report.
> 

Ok, here is what I did:

$ ip link set can0 up type can bitrate 1000000
$ ip link set can1 up type can bitrate 1000000 berr-reporting on
$ ip -d -s link
5: can0: <NOARP,UP,LOWER_UP,ECHO> mtu 16 qdisc pfifo_fast state UNKNOWN qlen 10
    link/can       
    can state ERROR-ACTIVE (berr-counter tx 0 rx 0) restart-ms 0
    bitrate 1000000 sample-point 0.750
    tq 125 prop-seg 2 phase-seg1 3 phase-seg2 2 sjw 1
    janz-ican3: tseg1 1..16 tseg2 1..8 sjw 1..4 brp 1..64 brp-inc 1
    clock 8000000  
    re-started bus-errors arbit-lost error-warn error-pass bus-off
    0          0          0          0          0          0
    RX: bytes  packets  errors  dropped overrun mcast
    0          0        0       0       0       0
    TX: bytes  packets  errors  dropped carrier collsns
    0          0        0       0       0       0
6: can1: <NOARP,UP,LOWER_UP,ECHO> mtu 16 qdisc pfifo_fast state UNKNOWN qlen 10
    link/can       
    can <BERR-REPORTING> state ERROR-ACTIVE (berr-counter tx 0 rx 0) restart-ms 0
    bitrate 1000000 sample-point 0.750
    tq 125 prop-seg 2 phase-seg1 3 phase-seg2 2 sjw 1
    janz-ican3: tseg1 1..16 tseg2 1..8 sjw 1..4 brp 1..64 brp-inc 1
    clock 8000000  
    re-started bus-errors arbit-lost error-warn error-pass bus-off
    0          0          0          0          0          0
    RX: bytes  packets  errors  dropped overrun mcast
    0          0        0       0       0       0
    TX: bytes  packets  errors  dropped carrier collsns
    0          0        0       0       0       0

Now, in seperate windows, I ran cansequence and candump. I stopped
cansequence when it could not send any more packets (due to the cable
being unplugged).

$ cansequence -v -e -p can0
$ cansequence -v -e -p can1
$ candump any,0~0,#FFFFFFFF
  can0  20000004  [8] 00 08 00 00 00 00 00 00   ERRORFRAME
  can1  20000088  [8] 00 00 80 19 00 00 00 00   ERRORFRAME
  can1  20000088  [8] 00 00 80 19 00 00 00 00   ERRORFRAME
  can1  20000088  [8] 00 00 80 19 00 00 00 00   ERRORFRAME
  can1  20000088  [8] 00 00 80 19 00 00 00 00   ERRORFRAME
  can1  20000088  [8] 00 00 80 19 00 00 00 00   ERRORFRAME
  can1  20000088  [8] 00 00 80 19 00 00 00 00   ERRORFRAME
  can1  20000088  [8] 00 00 80 19 00 00 00 00   ERRORFRAME
  can1  20000088  [8] 00 00 80 19 00 00 00 00   ERRORFRAME
  can1  20000088  [8] 00 00 80 19 00 00 00 00   ERRORFRAME
  can1  20000088  [8] 00 00 80 19 00 00 00 00   ERRORFRAME
  can1  20000088  [8] 00 00 80 19 00 00 00 00   ERRORFRAME
  can1  20000004  [8] 00 08 00 00 00 00 00 00   ERRORFRAME
  can1  20000088  [8] 00 00 80 19 00 00 00 00   ERRORFRAME
  can1  20000088  [8] 00 00 80 19 00 00 00 00   ERRORFRAME
  can1  20000088  [8] 00 00 80 19 00 00 00 00   ERRORFRAME
  can1  20000088  [8] 00 00 80 19 00 00 00 00   ERRORFRAME

This last message is repeated lots more times. That's the flooding we're
avoiding with berr-reporting off.

I see two types of messages here:
1) bus error (only on can1)
2) controller problems -- tx warning limit reached (both)

Am I missing some message? My error frame generation was mostly copied
from the sja1000 driver.

$ ip -d -s link
5: can0: <NOARP,UP,LOWER_UP,ECHO> mtu 16 qdisc pfifo_fast state UNKNOWN qlen 10
    link/can 
    can state ERROR-WARNING (berr-counter tx 128 rx 0) restart-ms 0 
    bitrate 1000000 sample-point 0.750 
    tq 125 prop-seg 2 phase-seg1 3 phase-seg2 2 sjw 1
    janz-ican3: tseg1 1..16 tseg2 1..8 sjw 1..4 brp 1..64 brp-inc 1
    clock 8000000
    re-started bus-errors arbit-lost error-warn error-pass bus-off
    0          0          0          1          0          0         
    RX: bytes  packets  errors  dropped overrun mcast   
    16         0        2       0       0       0      
    TX: bytes  packets  errors  dropped carrier collsns 
    513        513      0       0       0       0      
6: can1: <NOARP,UP,LOWER_UP,ECHO> mtu 16 qdisc pfifo_fast state UNKNOWN qlen 10
    link/can 
    can <BERR-REPORTING> state ERROR-WARNING (berr-counter tx 128 rx 0) restart-ms 0 
    bitrate 1000000 sample-point 0.750 
    tq 125 prop-seg 2 phase-seg1 3 phase-seg2 2 sjw 1
    janz-ican3: tseg1 1..16 tseg2 1..8 sjw 1..4 brp 1..64 brp-inc 1
    clock 8000000
    re-started bus-errors arbit-lost error-warn error-pass bus-off
    0          126        0          1          0          0         
    RX: bytes  packets  errors  dropped overrun mcast   
    1024       0        254     0       0       0      
    TX: bytes  packets  errors  dropped carrier collsns 
    513        513      0       0       0       0      


> >>> I also noticed that I can enable "self test mode" and "listen only mode"
> >>> using the same firmware command. It appears that there are netlink
> >>> messages for this as well. Should I try and support these, too? I don't
> >>> really have any use for them (yet). I assume "self test mode" is
> >>> equivalent to "loopback mode" in the netlink messages.
> >> List-only is straight forward while "self test mode" is not exactly like
> >> "loopback mode", IIRC. Feel free to send a follow-up patch when you have
> >> time for a thorough implementation and testing. It's also on my to-do
> >> list for the SJA1000.
> >>
> > 
> > Ok, then I'll put this off for a while. Feel free to pester me about it
> > when there is a working implementation in the SJA1000 driver for me to
> > borrow from. :)
> 
> I will let you know when I have something working.
> 

Thanks,
Ira
