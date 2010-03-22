From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH 2/3] can: add support for Janz VMOD-ICAN3 Intelligent
	CAN	module
Date: Mon, 22 Mar 2010 20:17:10 +0100
Message-ID: <4BA7C236.9060609@grandegger.com>
References: <>
	<1268930324-29841-3-git-send-email-iws@ovro.caltech.edu>	<4BA33D5A.8070000@grandegger.com>	<20100319151914.GB13672@ovro.caltech.edu>	<4BA39C05.8050800@grandegger.com>	<20100319200325.GE13672@ovro.caltech.edu>	<4BA3DAF1.4090206@grandegger.com>	<20100319215227.GF13672@ovro.caltech.edu>	<4BA47F64.8030108@grandegger.com>
	<20100322155318.GA19251@ovro.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org
To: "Ira W. Snyder" <iws-lulEs6mt1IksTUYHLfqkUA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20100322155318.GA19251-lulEs6mt1IksTUYHLfqkUA@public.gmane.org>
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

Ira W. Snyder wrote:
> On Sat, Mar 20, 2010 at 08:55:16AM +0100, Wolfgang Grandegger wrote:
>> Ira W. Snyder wrote:
[snip]
>>> Does this seem right? It seems pretty good to me.
>> Yes, I'm just missing an error-passive message. What state does "ip -d
>> link show can0" report.
>>
> 
> Ok, here is what I did:
> 
> $ ip link set can0 up type can bitrate 1000000
> $ ip link set can1 up type can bitrate 1000000 berr-reporting on
> $ ip -d -s link
> 5: can0: <NOARP,UP,LOWER_UP,ECHO> mtu 16 qdisc pfifo_fast state UNKNOWN qlen 10
>     link/can       
>     can state ERROR-ACTIVE (berr-counter tx 0 rx 0) restart-ms 0
>     bitrate 1000000 sample-point 0.750
>     tq 125 prop-seg 2 phase-seg1 3 phase-seg2 2 sjw 1
>     janz-ican3: tseg1 1..16 tseg2 1..8 sjw 1..4 brp 1..64 brp-inc 1
>     clock 8000000  
>     re-started bus-errors arbit-lost error-warn error-pass bus-off
>     0          0          0          0          0          0
>     RX: bytes  packets  errors  dropped overrun mcast
>     0          0        0       0       0       0
>     TX: bytes  packets  errors  dropped carrier collsns
>     0          0        0       0       0       0
> 6: can1: <NOARP,UP,LOWER_UP,ECHO> mtu 16 qdisc pfifo_fast state UNKNOWN qlen 10
>     link/can       
>     can <BERR-REPORTING> state ERROR-ACTIVE (berr-counter tx 0 rx 0) restart-ms 0
>     bitrate 1000000 sample-point 0.750
>     tq 125 prop-seg 2 phase-seg1 3 phase-seg2 2 sjw 1
>     janz-ican3: tseg1 1..16 tseg2 1..8 sjw 1..4 brp 1..64 brp-inc 1
>     clock 8000000  
>     re-started bus-errors arbit-lost error-warn error-pass bus-off
>     0          0          0          0          0          0
>     RX: bytes  packets  errors  dropped overrun mcast
>     0          0        0       0       0       0
>     TX: bytes  packets  errors  dropped carrier collsns
>     0          0        0       0       0       0
> 
> Now, in seperate windows, I ran cansequence and candump. I stopped
> cansequence when it could not send any more packets (due to the cable
> being unplugged).
> 
> $ cansequence -v -e -p can0
> $ cansequence -v -e -p can1
> $ candump any,0~0,#FFFFFFFF
>   can0  20000004  [8] 00 08 00 00 00 00 00 00   ERRORFRAME
>   can1  20000088  [8] 00 00 80 19 00 00 00 00   ERRORFRAME
>   can1  20000088  [8] 00 00 80 19 00 00 00 00   ERRORFRAME
>   can1  20000088  [8] 00 00 80 19 00 00 00 00   ERRORFRAME
>   can1  20000088  [8] 00 00 80 19 00 00 00 00   ERRORFRAME
>   can1  20000088  [8] 00 00 80 19 00 00 00 00   ERRORFRAME
>   can1  20000088  [8] 00 00 80 19 00 00 00 00   ERRORFRAME
>   can1  20000088  [8] 00 00 80 19 00 00 00 00   ERRORFRAME
>   can1  20000088  [8] 00 00 80 19 00 00 00 00   ERRORFRAME
>   can1  20000088  [8] 00 00 80 19 00 00 00 00   ERRORFRAME
>   can1  20000088  [8] 00 00 80 19 00 00 00 00   ERRORFRAME
>   can1  20000088  [8] 00 00 80 19 00 00 00 00   ERRORFRAME
>   can1  20000004  [8] 00 08 00 00 00 00 00 00   ERRORFRAME
>   can1  20000088  [8] 00 00 80 19 00 00 00 00   ERRORFRAME
>   can1  20000088  [8] 00 00 80 19 00 00 00 00   ERRORFRAME
>   can1  20000088  [8] 00 00 80 19 00 00 00 00   ERRORFRAME
>   can1  20000088  [8] 00 00 80 19 00 00 00 00   ERRORFRAME
> 
> This last message is repeated lots more times. That's the flooding we're
> avoiding with berr-reporting off.
> 
> I see two types of messages here:
> 1) bus error (only on can1)
> 2) controller problems -- tx warning limit reached (both)
> 
> Am I missing some message? My error frame generation was mostly copied
> from the sja1000 driver.

It seem that you are not getting the error passive interrupt even...

> $ ip -d -s link
> 5: can0: <NOARP,UP,LOWER_UP,ECHO> mtu 16 qdisc pfifo_fast state UNKNOWN qlen 10
>     link/can 
>     can state ERROR-WARNING (berr-counter tx 128 rx 0) restart-ms 0 

if the hardware already reports >= 128 errors --^.

>     bitrate 1000000 sample-point 0.750 
>     tq 125 prop-seg 2 phase-seg1 3 phase-seg2 2 sjw 1
>     janz-ican3: tseg1 1..16 tseg2 1..8 sjw 1..4 brp 1..64 brp-inc 1
>     clock 8000000
>     re-started bus-errors arbit-lost error-warn error-pass bus-off
>     0          0          0          1          0          0         
>     RX: bytes  packets  errors  dropped overrun mcast   
>     16         0        2       0       0       0      
>     TX: bytes  packets  errors  dropped carrier collsns 
>     513        513      0       0       0       0      
> 6: can1: <NOARP,UP,LOWER_UP,ECHO> mtu 16 qdisc pfifo_fast state UNKNOWN qlen 10
>     link/can 
>     can <BERR-REPORTING> state ERROR-WARNING (berr-counter tx 128 rx 0) restart-ms 0 
>     bitrate 1000000 sample-point 0.750 
>     tq 125 prop-seg 2 phase-seg1 3 phase-seg2 2 sjw 1
>     janz-ican3: tseg1 1..16 tseg2 1..8 sjw 1..4 brp 1..64 brp-inc 1
>     clock 8000000
>     re-started bus-errors arbit-lost error-warn error-pass bus-off
>     0          126        0          1          0          0         

But that's mabe because you stopped the test too early (just 126 bus errors).

>     RX: bytes  packets  errors  dropped overrun mcast   
>     1024       0        254     0       0       0      
>     TX: bytes  packets  errors  dropped carrier collsns 
>     513        513      0       0       0       0      

When I send out messages without cable connected I get:

-bash-3.2# ./ip -d -s link show can0
2: can0: <NOARP,UP,LOWER_UP,ECHO> mtu 16 qdisc pfifo_fast state UNKNOWN qlen 10
    link/can 
    can <BERR-REPORTING> state ERROR-PASSIVE (berr-counter tx 128 rx 0) restart-ms 0 
    bitrate 500000 sample-point 0.875 
    tq 125 prop-seg 6 phase-seg1 7 phase-seg2 2 sjw 1
    sja1000: tseg1 1..16 tseg2 1..8 sjw 1..4 brp 1..64 brp-inc 1
    clock 8000000
    re-started bus-errors arbit-lost error-warn error-pass bus-off
    0          54101      0          1          1          0         
    RX: bytes  packets  errors  dropped overrun mcast   
    432808     54101    54101   0       0       0      
    TX: bytes  packets  errors  dropped carrier collsns 
    0          0        0       0       0       0      

The following output is without BERR-REPORTING:

-bash-3.2# ./candump -t d any,0:0,#FFFFFFFF
 (0.000000)  can0  20000004  [8] 00 08 00 00 00 00 60 00   ERRORFRAME
 (0.000474)  can0  20000004  [8] 00 20 00 00 00 00 80 00   ERRORFRAME
                                                    ^  ^
                                                   TX RX error counter

The patch I mentioned also copies the rx and tx error counter values to
the data field 6 and 7.

Wolfgang.
