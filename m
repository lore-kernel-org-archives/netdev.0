From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH net-next v2 2/4] can: cc770: add
 legacy ISA bus driver for the CC770 and AN82527
Date: Wed, 07 Dec 2011 14:42:44 +0100
Message-ID: <4EDF6D54.2060503@grandegger.com>
References: <1322214204-1121-1-git-send-email-wg@grandegger.com>
	<1322214204-1121-3-git-send-email-wg@grandegger.com>
	<4ED0FEC5.3070108@hartkopp.net> <4ED34CAD.7040000@essax.com>
	<4ED351A8.8000102@grandegger.com> <4ED37885.8080909@essax.com>
	<4ED3B198.2040308@hartkopp.net> <4ED4A2EC.40103@grandegger.com>
	<4EDBC05D.8070109@essax.com> <4EDBC25D.50405@grandegger.com>
	<4EDE8435.5080100@essax.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>, linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, socketcan-users-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
To: info-PyqsHJVlJN8AvxtiuMwx3w@public.gmane.org
Return-path: <socketcan-users-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4EDE8435.5080100-PyqsHJVlJN8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-users>,
	<mailto:socketcan-users-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-users>
List-Post: <mailto:socketcan-users-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-users-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-users>,
	<mailto:socketcan-users-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-users-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-users-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Wolfgang,

On 12/06/2011 10:08 PM, Wolfgang Zarre wrote:
> Hello Wolfgang,
> 
>> Hi Wolfgang,
>>
>> On 12/04/2011 07:47 PM, Wolfgang Zarre wrote:
...
>>>
>>> Should be not a problem at all.
>>
>> Great, thanks.
> 
> Ok, here we go:
> 
> uname -r: 3.2.0-rc4
> 
> modprobe cc770_isa irq=0xa port=0x384 indirect=1 cir=0x61 bcr=0x4A
> ip link set can0 up type can bitrate 500000;
> 
> kern.log
> Dec  6 20:42:19 svserv01 kernel: [ 2111.900735] CAN device driver interface
> Dec  6 20:42:19 svserv01 kernel: [ 2111.903072] cc770: CAN netdevice driver
> Dec  6 20:42:19 svserv01 kernel: [ 2111.904692] cc770_isa: platform
> device 0: port=0x384, mem=0x0, irq=10
> Dec  6 20:42:19 svserv01 kernel: [ 2111.904726] cc770_isa cc770_isa.0:
> probing idx=0: port=0x384, mem=0x0, irq=10
> Dec  6 20:42:19 svserv01 kernel: [ 2111.904779] cc770_isa cc770_isa.0:
> (unregistered net_device): i82527 mode with additional functions
> Dec  6 20:42:19 svserv01 kernel: [ 2111.906407] cc770_isa cc770_isa.0:
> device registered (reg_base=0x00000384, irq=10)
> Dec  6 20:42:19 svserv01 kernel: [ 2111.906457] cc770_isa: driver for
> max. 8 devices registered
>   6 20:44:17 svserv01 kernel: [ 2229.886845] cc770_isa cc770_isa.0:
> can0: setting BTR0=0x00 BTR1=0x1c
> Dec  6 20:44:17 svserv01 kernel: [ 2229.886920] cc770_isa cc770_isa.0:
> can0: Message object 15 for RX data, RTR, SFF and EFF
> Dec  6 20:44:17 svserv01 kernel: [ 2229.886937] cc770_isa cc770_isa.0:
> can0: Message object 11 for TX data, RTR, SFF and EFF
> Dec  6 20:52:40 svserv01 kernel: [ 2733.172845] can: controller area
> network core (rev 20090105 abi 8)
> Dec  6 20:52:40 svserv01 kernel: [ 2733.172967] NET: Registered protocol
> family 29
> Dec  6 20:52:40 svserv01 kernel: [ 2733.178187] can: raw protocol (rev
> 20090105)
> 
> 
> ip -d -s link show
> 4: can0: <NOARP,UP,LOWER_UP,ECHO> mtu 16 qdisc pfifo_fast state UNKNOWN
> qlen 10
>     link/can
>     can state ERROR-ACTIVE (berr-counter tx 0 rx 0) restart-ms 0
>     bitrate 500000 sample-point 0.875
>     tq 125 prop-seg 6 phase-seg1 7 phase-seg2 2 sjw 1
>     cc770: tseg1 1..16 tseg2 1..8 sjw 1..4 brp 1..64 brp-inc 1
>     clock 8000000
>     re-started bus-errors arbit-lost error-warn error-pass bus-off
>     0          0          0          0          0          0
>     RX: bytes  packets  errors  dropped overrun mcast
>     0          0        0       0       0       0
>     TX: bytes  packets  errors  dropped carrier collsns
>     0          0        0       0       0       0
> 
> 
> After rebooting the PLC with proprietary buggy kernel:
> 4: can0: <NOARP,UP,LOWER_UP,ECHO> mtu 16 qdisc pfifo_fast state UNKNOWN
> qlen 10
>     link/can
>     can state ERROR-ACTIVE (berr-counter tx 0 rx 0) restart-ms 0
>     bitrate 500000 sample-point 0.875
>     tq 125 prop-seg 6 phase-seg1 7 phase-seg2 2 sjw 1
>     cc770: tseg1 1..16 tseg2 1..8 sjw 1..4 brp 1..64 brp-inc 1
>     clock 8000000
>     re-started bus-errors arbit-lost error-warn error-pass bus-off
>     0          0          0          0          0          0
>     RX: bytes  packets  errors  dropped overrun mcast
>     414        267      0       267     0       0
>     TX: bytes  packets  errors  dropped carrier collsns
>     0          0        0       0       0       0
> 
> 
> 
> After sending 100,000 PDO's with 13ms displacement:
> 4: can0: <NOARP,UP,LOWER_UP,ECHO> mtu 16 qdisc pfifo_fast state UNKNOWN
> qlen 10
>     link/can
>     can state ERROR-ACTIVE (berr-counter tx 0 rx 0) restart-ms 0
>     bitrate 500000 sample-point 0.875
>     tq 125 prop-seg 6 phase-seg1 7 phase-seg2 2 sjw 1
>     cc770: tseg1 1..16 tseg2 1..8 sjw 1..4 brp 1..64 brp-inc 1
>     clock 8000000
>     re-started bus-errors arbit-lost error-warn error-pass bus-off
>     0          0          0          0          0          0
>     RX: bytes  packets  errors  dropped overrun mcast
>     4544       4284     0       331     0       0
>     TX: bytes  packets  errors  dropped carrier collsns
>     802660     202653   0       0       0       0
> 
> 
> The dropped ones of RX may be the not processed input packages and
> therefore ok.
> 
> Let me know if You need more or some other tests.

You could provoke some state changes or bus-off conditions to see if the
berr-counter shows reasonable results. I'm currently consolidating and
unifying error state and bus-off handling. Would be nice if you could do
some further tests when I have the patches ready...

Thanks for testing.

Wolfgang.
