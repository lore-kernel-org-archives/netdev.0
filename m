From: Wolfgang Zarre <info@essax.com>
Subject: Re: [PATCH net-next v2 2/4] can: cc770: add legacy ISA bus driver
 for the CC770 and AN82527
Date: Sun, 11 Dec 2011 19:33:18 +0100
Message-ID: <4EE4F76E.3000506@essax.com>
References: <1322214204-1121-1-git-send-email-wg@grandegger.com> <1322214204-1121-3-git-send-email-wg@grandegger.com> <4ED0FEC5.3070108@hartkopp.net> <4ED34CAD.7040000@essax.com> <4ED351A8.8000102@grandegger.com> <4ED37885.8080909@essax.com> <4ED3B198.2040308@hartkopp.net> <4ED4A2EC.40103@grandegger.com> <4EDBC05D.8070109@essax.com> <4EDBC25D.50405@grandegger.com> <4EDE8435.5080100@essax.com> <4EDF6D54.2060503@grandegger.com> <4EE1E26B.6090308@grandegger.com>
Reply-To: info@essax.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Oliver Hartkopp <socketcan@hartkopp.net>, netdev@vger.kernel.org,
	linux-can@vger.kernel.org, socketcan-users@lists.berlios.de,
	IreneV <boir1@yandex.ru>,
	Stanislav Yelenskiy <stanislavelensky@yahoo.com>
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <4EE1E26B.6090308@grandegger.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Wolfgang,
> On 12/07/2011 02:42 PM, Wolfgang Grandegger wrote:
>> Hi Wolfgang,
>>
>> On 12/06/2011 10:08 PM, Wolfgang Zarre wrote:
>>> Hello Wolfgang,
>>>
>>>> Hi Wolfgang,
>>>>
>>>> On 12/04/2011 07:47 PM, Wolfgang Zarre wrote:
>> ...
>>>>>
>>>>> Should be not a problem at all.
>>>>
>>>> Great, thanks.
>>>
>>> Ok, here we go:
>>>
>>> uname -r: 3.2.0-rc4
>>>
>>> modprobe cc770_isa irq=0xa port=0x384 indirect=1 cir=0x61 bcr=0x4A
>>> ip link set can0 up type can bitrate 500000;
>>>
>>> kern.log
>>> Dec  6 20:42:19 svserv01 kernel: [ 2111.900735] CAN device driver interface
>>> Dec  6 20:42:19 svserv01 kernel: [ 2111.903072] cc770: CAN netdevice driver
>>> Dec  6 20:42:19 svserv01 kernel: [ 2111.904692] cc770_isa: platform
>>> device 0: port=0x384, mem=0x0, irq=10
>>> Dec  6 20:42:19 svserv01 kernel: [ 2111.904726] cc770_isa cc770_isa.0:
>>> probing idx=0: port=0x384, mem=0x0, irq=10
>>> Dec  6 20:42:19 svserv01 kernel: [ 2111.904779] cc770_isa cc770_isa.0:
>>> (unregistered net_device): i82527 mode with additional functions
>>> Dec  6 20:42:19 svserv01 kernel: [ 2111.906407] cc770_isa cc770_isa.0:
>>> device registered (reg_base=0x00000384, irq=10)
>>> Dec  6 20:42:19 svserv01 kernel: [ 2111.906457] cc770_isa: driver for
>>> max. 8 devices registered
>>>    6 20:44:17 svserv01 kernel: [ 2229.886845] cc770_isa cc770_isa.0:
>>> can0: setting BTR0=0x00 BTR1=0x1c
>>> Dec  6 20:44:17 svserv01 kernel: [ 2229.886920] cc770_isa cc770_isa.0:
>>> can0: Message object 15 for RX data, RTR, SFF and EFF
>>> Dec  6 20:44:17 svserv01 kernel: [ 2229.886937] cc770_isa cc770_isa.0:
>>> can0: Message object 11 for TX data, RTR, SFF and EFF
>>> Dec  6 20:52:40 svserv01 kernel: [ 2733.172845] can: controller area
>>> network core (rev 20090105 abi 8)
>>> Dec  6 20:52:40 svserv01 kernel: [ 2733.172967] NET: Registered protocol
>>> family 29
>>> Dec  6 20:52:40 svserv01 kernel: [ 2733.178187] can: raw protocol (rev
>>> 20090105)
>>>
>>>
>>> ip -d -s link show
>>> 4: can0:<NOARP,UP,LOWER_UP,ECHO>  mtu 16 qdisc pfifo_fast state UNKNOWN
>>> qlen 10
>>>      link/can
>>>      can state ERROR-ACTIVE (berr-counter tx 0 rx 0) restart-ms 0
>>>      bitrate 500000 sample-point 0.875
>>>      tq 125 prop-seg 6 phase-seg1 7 phase-seg2 2 sjw 1
>>>      cc770: tseg1 1..16 tseg2 1..8 sjw 1..4 brp 1..64 brp-inc 1
>>>      clock 8000000
>>>      re-started bus-errors arbit-lost error-warn error-pass bus-off
>>>      0          0          0          0          0          0
>>>      RX: bytes  packets  errors  dropped overrun mcast
>>>      0          0        0       0       0       0
>>>      TX: bytes  packets  errors  dropped carrier collsns
>>>      0          0        0       0       0       0
>>>
>>>
>>> After rebooting the PLC with proprietary buggy kernel:
>>> 4: can0:<NOARP,UP,LOWER_UP,ECHO>  mtu 16 qdisc pfifo_fast state UNKNOWN
>>> qlen 10
>>>      link/can
>>>      can state ERROR-ACTIVE (berr-counter tx 0 rx 0) restart-ms 0
>>>      bitrate 500000 sample-point 0.875
>>>      tq 125 prop-seg 6 phase-seg1 7 phase-seg2 2 sjw 1
>>>      cc770: tseg1 1..16 tseg2 1..8 sjw 1..4 brp 1..64 brp-inc 1
>>>      clock 8000000
>>>      re-started bus-errors arbit-lost error-warn error-pass bus-off
>>>      0          0          0          0          0          0
>>>      RX: bytes  packets  errors  dropped overrun mcast
>>>      414        267      0       267     0       0
>>>      TX: bytes  packets  errors  dropped carrier collsns
>>>      0          0        0       0       0       0
>>>
>>>
>>>
>>> After sending 100,000 PDO's with 13ms displacement:
>>> 4: can0:<NOARP,UP,LOWER_UP,ECHO>  mtu 16 qdisc pfifo_fast state UNKNOWN
>>> qlen 10
>>>      link/can
>>>      can state ERROR-ACTIVE (berr-counter tx 0 rx 0) restart-ms 0
>>>      bitrate 500000 sample-point 0.875
>>>      tq 125 prop-seg 6 phase-seg1 7 phase-seg2 2 sjw 1
>>>      cc770: tseg1 1..16 tseg2 1..8 sjw 1..4 brp 1..64 brp-inc 1
>>>      clock 8000000
>>>      re-started bus-errors arbit-lost error-warn error-pass bus-off
>>>      0          0          0          0          0          0
>>>      RX: bytes  packets  errors  dropped overrun mcast
>>>      4544       4284     0       331     0       0
>>>      TX: bytes  packets  errors  dropped carrier collsns
>>>      802660     202653   0       0       0       0
>>>
>>>
>>> The dropped ones of RX may be the not processed input packages and
>>> therefore ok.
>>>
>>> Let me know if You need more or some other tests.
>>
>> You could provoke some state changes or bus-off conditions to see if the
>> berr-counter shows reasonable results. I'm currently consolidating and
>> unifying error state and bus-off handling. Would be nice if you could do
>> some further tests when I have the patches ready...
>
> I just pushed the mentioned modifications to the "devel" branch of my
> "wg-linux-can-next" [1] repository. You can get it as shown below:
>
>    $ git clone --reference=<some-recent-net-next-tree>  \
>        git://gitorious.org/~wgrandegger/linux-can/wg-linux-can-next.git
>    $ git checkout -b devel devel
>
> [1] https://gitorious.org/~wgrandegger/linux-can/wg-linux-can-next
>
> Wolfgang.

OK, I was trying so far and You will find below the results.
Just FYI the states on the PLC side couldn't be verified because the function
provided by the manufacturer is not working at all and CAN analyser was not
available.

We are running CANopen and therefore the PLC will send automatically a heartbeat.

I produced the bus-off state through a short circuit between L/H which was
working as expected.

A bit odd was that on the second try I had to reload the module
because a ip down/up was not enough.

Let me know if You would need further tests or different procedure.



Starting procedure:
Cable disconnected
Restarting PC with new driver
Restarting PLC
Connecting cable
modprobe cc770_isa irq=0xa port=0x384 indirect=1 cir=0x61 bcr=0x4A
dmesg:
[  221.996751] CAN device driver interface
[  222.036036] cc770: CAN netdevice driver
[  222.054260] cc770_isa: platform device 0: port=0x384, mem=0x0, irq=10
[  222.054293] cc770_isa cc770_isa.0: probing idx=0: port=0x384, mem=0x0, irq=10
[  222.054343] cc770_isa cc770_isa.0: (unregistered net_device): i82527 mode with additional functions
[  222.055925] cc770_isa cc770_isa.0: device registered (reg_base=0x00000384, irq=10)
[  222.055972] cc770_isa: driver for max. 8 devices registered

ip -d -s link show can0
4: can0: <NOARP,ECHO> mtu 16 qdisc noop state DOWN qlen 10
     link/can
     can state STOPPED (berr-counter tx 92 rx 103) restart-ms 0
     bitrate 0 sample-point 0.000
     tq 0 prop-seg 0 phase-seg1 0 phase-seg2 0 sjw 0
     cc770: tseg1 1..16 tseg2 1..8 sjw 1..4 brp 1..64 brp-inc 1
     clock 8000000
     re-started bus-errors arbit-lost error-warn error-pass bus-off
     0          0          0          0          0          0
     RX: bytes  packets  errors  dropped overrun mcast
     0          0        0       0       0       0
     TX: bytes  packets  errors  dropped carrier collsns
     0          0        0       0       0       0

ip link set can0 up type can bitrate 500000
dmesg:
[  287.871983] cc770_isa cc770_isa.0: can0: setting BTR0=0x00 BTR1=0x1c
[  287.872103] cc770_isa cc770_isa.0: can0: Message object 15 for RX data, RTR, SFF and EFF
[  287.872119] cc770_isa cc770_isa.0: can0: Message object 11 for TX data, RTR, SFF and EFF

ip -d -s link show can0
4: can0: <NOARP,UP,LOWER_UP,ECHO> mtu 16 qdisc pfifo_fast state UNKNOWN qlen 10
     link/can
     can state ERROR-ACTIVE (berr-counter tx 0 rx 0) restart-ms 0
     bitrate 500000 sample-point 0.875
     tq 125 prop-seg 6 phase-seg1 7 phase-seg2 2 sjw 1
     cc770: tseg1 1..16 tseg2 1..8 sjw 1..4 brp 1..64 brp-inc 1
     clock 8000000
     re-started bus-errors arbit-lost error-warn error-pass bus-off
     0          0          0          0          0          0
     RX: bytes  packets  errors  dropped overrun mcast
     0          0        0       0       0       0
     TX: bytes  packets  errors  dropped carrier collsns
     0          0        0       0       0       0

PLC stays in unknown CAN state (as usual )
Rebooting PLC

dmesg:
[  466.169054] can: controller area network core (rev 20090105 abi 8)
[  466.169178] NET: Registered protocol family 29
[  466.174339] can: raw protocol (rev 20090105)


PLC is sending heartbeat
Starting PC heartbeats

ip -d -s link show can0
4: can0: <NOARP,UP,LOWER_UP,ECHO> mtu 16 qdisc pfifo_fast state UNKNOWN qlen 10
     link/can
     can state ERROR-ACTIVE (berr-counter tx 0 rx 0) restart-ms 0
     bitrate 500000 sample-point 0.875
     tq 125 prop-seg 6 phase-seg1 7 phase-seg2 2 sjw 1
     cc770: tseg1 1..16 tseg2 1..8 sjw 1..4 brp 1..64 brp-inc 1
     clock 8000000
     re-started bus-errors arbit-lost error-warn error-pass bus-off
     0          0          0          0          0          0
     RX: bytes  packets  errors  dropped overrun mcast
     513        365      0       0       0       0
     TX: bytes  packets  errors  dropped carrier collsns
     20         20       0       0       0       0


Producing L/H short circuit for 2 seconds
dmesg:
[  885.409058] cc770_isa cc770_isa.0: can0: status interrupt (0x5b)
[  885.420475] cc770_isa cc770_isa.0: can0: status interrupt (0xc5)
[  885.420496] cc770_isa cc770_isa.0: can0: bus-off

ip -d -s link show can0
4: can0: <NO-CARRIER,NOARP,UP,ECHO> mtu 16 qdisc pfifo_fast state DOWN qlen 10
     link/can
     can state BUS-OFF (berr-counter tx 92 rx 103) restart-ms 0
     bitrate 500000 sample-point 0.875
     tq 125 prop-seg 6 phase-seg1 7 phase-seg2 2 sjw 1
     cc770: tseg1 1..16 tseg2 1..8 sjw 1..4 brp 1..64 brp-inc 1
     clock 8000000
     re-started bus-errors arbit-lost error-warn error-pass bus-off
     0          0          0          1          0          1
     RX: bytes  packets  errors  dropped overrun mcast
     544        382      0       0       0       0
     TX: bytes  packets  errors  dropped carrier collsns
     30         29       0       0       0       0

Sending and receiving stops.

Trying to recover on PC:
ip link set can0 down;
ip -d -s link show can0
4: can0: <NOARP,ECHO> mtu 16 qdisc pfifo_fast state DOWN qlen 10
     link/can
     can state STOPPED (berr-counter tx 92 rx 103) restart-ms 0
     bitrate 500000 sample-point 0.875
     tq 125 prop-seg 6 phase-seg1 7 phase-seg2 2 sjw 1
     cc770: tseg1 1..16 tseg2 1..8 sjw 1..4 brp 1..64 brp-inc 1
     clock 8000000
     re-started bus-errors arbit-lost error-warn error-pass bus-off
     0          0          0          1          0          1
     RX: bytes  packets  errors  dropped overrun mcast
     544        382      0       0       0       0
     TX: bytes  packets  errors  dropped carrier collsns
     30         29       0       1       0       0

ip link set can0 up type can bitrate 500000;
dmesg:
[ 1090.937778] cc770_isa cc770_isa.0: can0: setting BTR0=0x00 BTR1=0x1c
[ 1090.937869] cc770_isa cc770_isa.0: can0: Message object 15 for RX data, RTR, SFF and EFF
[ 1090.937885] cc770_isa cc770_isa.0: can0: Message object 11 for TX data, RTR, SFF and EFF
[ 1090.938050] ADDRCONF(NETDEV_CHANGE): can0: link becomes ready
[ 1090.940769] cc770_isa cc770_isa.0: can0: status interrupt (0x5)

ip -d -s link show can0
4: can0: <NOARP,UP,LOWER_UP,ECHO> mtu 16 qdisc pfifo_fast state UP qlen 10
     link/can
     can state ERROR-ACTIVE (berr-counter tx 0 rx 0) restart-ms 0
     bitrate 500000 sample-point 0.875
     tq 125 prop-seg 6 phase-seg1 7 phase-seg2 2 sjw 1
     cc770: tseg1 1..16 tseg2 1..8 sjw 1..4 brp 1..64 brp-inc 1
     clock 8000000
     re-started bus-errors arbit-lost error-warn error-pass bus-off
     0          0          0          1          0          1
     RX: bytes  packets  errors  dropped overrun mcast
     552        383      0       0       0       0
     TX: bytes  packets  errors  dropped carrier collsns
     30         29       0       1       0       0

PLC in unknown state but not sending heartbeat,
Rebooting PLC
PLC sends heartbeat but PC cannot send (buffer overrun)

ip -d -s link show can0
4: can0: <NOARP,UP,LOWER_UP,ECHO> mtu 16 qdisc pfifo_fast state UP qlen 10
     link/can
     can state ERROR-ACTIVE (berr-counter tx 0 rx 0) restart-ms 0
     bitrate 500000 sample-point 0.875
     tq 125 prop-seg 6 phase-seg1 7 phase-seg2 2 sjw 1
     cc770: tseg1 1..16 tseg2 1..8 sjw 1..4 brp 1..64 brp-inc 1
     clock 8000000
     re-started bus-errors arbit-lost error-warn error-pass bus-off
     0          0          0          1          0          1
     RX: bytes  packets  errors  dropped overrun mcast
     582        398      0       0       0       0
     TX: bytes  packets  errors  dropped carrier collsns
     30         29       0       1       0       0


Reloading driver

modprobe -r cc770_isa
dmesg:
[ 1457.133359] cc770: driver removed

modprobe cc770_isa irq=0xa port=0x384 indirect=1 cir=0x61 bcr=0x4A
dmesg:
[ 1474.051479] CAN device driver interface
[ 1474.053180] cc770: CAN netdevice driver
[ 1474.054416] cc770_isa: platform device 0: port=0x384, mem=0x0, irq=10
[ 1474.054449] cc770_isa cc770_isa.0: probing idx=0: port=0x384, mem=0x0, irq=10
[ 1474.054500] cc770_isa cc770_isa.0: (unregistered net_device): i82527 mode with additional functions
[ 1474.056097] cc770_isa cc770_isa.0: device registered (reg_base=0x00000384, irq=10)
[ 1474.056146] cc770_isa: driver for max. 8 devices registered

ip link set can0 up type can bitrate 500000;
[ 1484.586697] cc770_isa cc770_isa.0: can0: setting BTR0=0x00 BTR1=0x1c
[ 1484.586775] cc770_isa cc770_isa.0: can0: Message object 15 for RX data, RTR, SFF and EFF
[ 1484.586791] cc770_isa cc770_isa.0: can0: Message object 11 for TX data, RTR, SFF and EFF

Receiving and sending heartbeat
ip -d -s link show can0
5: can0: <NOARP,UP,LOWER_UP,ECHO> mtu 16 qdisc pfifo_fast state UNKNOWN qlen 10
     link/can
     can state ERROR-ACTIVE (berr-counter tx 0 rx 0) restart-ms 0
     bitrate 500000 sample-point 0.875
     tq 125 prop-seg 6 phase-seg1 7 phase-seg2 2 sjw 1
     cc770: tseg1 1..16 tseg2 1..8 sjw 1..4 brp 1..64 brp-inc 1
     clock 8000000
     re-started bus-errors arbit-lost error-warn error-pass bus-off
     0          0          0          0          0          0
     RX: bytes  packets  errors  dropped overrun mcast
     158        157      0       0       0       0
     TX: bytes  packets  errors  dropped carrier collsns
     16         16       0       0       0       0


-----------------------------------------

Producing L/H short circuit again for 2 seconds

dmesg:
[ 1719.018116] cc770_isa cc770_isa.0: can0: status interrupt (0x5b)

ip -d -s link show can0
5: can0: <NOARP,UP,LOWER_UP,ECHO> mtu 16 qdisc pfifo_fast state UNKNOWN qlen 10
     link/can
     can state ERROR-WARNING (berr-counter tx 128 rx 128) restart-ms 0
     bitrate 500000 sample-point 0.875
     tq 125 prop-seg 6 phase-seg1 7 phase-seg2 2 sjw 1
     cc770: tseg1 1..16 tseg2 1..8 sjw 1..4 brp 1..64 brp-inc 1
     clock 8000000
     re-started bus-errors arbit-lost error-warn error-pass bus-off
     0          0          0          1          0          0
     RX: bytes  packets  errors  dropped overrun mcast
     271        263      0       0       0       0
     TX: bytes  packets  errors  dropped carrier collsns
     88         87       0       0       0       0


Sending and receiving stops.

Trying to recover on PC with driver reload:
modprobe -r cc770_isa
dmesg:
[ 1820.358418] cc770: driver removed

modprobe cc770_isa irq=0xa port=0x384 indirect=1 cir=0x61 bcr=0x4A
dmesg:
[ 1826.810914] CAN device driver interface
[ 1826.812619] cc770: CAN netdevice driver
[ 1826.814126] cc770_isa: platform device 0: port=0x384, mem=0x0, irq=10
[ 1826.814158] cc770_isa cc770_isa.0: probing idx=0: port=0x384, mem=0x0, irq=10
[ 1826.814211] cc770_isa cc770_isa.0: (unregistered net_device): i82527 mode with additional functions
[ 1826.815789] cc770_isa cc770_isa.0: device registered (reg_base=0x00000384, irq=10)
[ 1826.815839] cc770_isa: driver for max. 8 devices registered

ip -d -s link show can0
6: can0: <NOARP,ECHO> mtu 16 qdisc noop state DOWN qlen 10
     link/can
     can state STOPPED (berr-counter tx 92 rx 103) restart-ms 0
     bitrate 0 sample-point 0.000
     tq 0 prop-seg 0 phase-seg1 0 phase-seg2 0 sjw 0
     cc770: tseg1 1..16 tseg2 1..8 sjw 1..4 brp 1..64 brp-inc 1
     clock 8000000
     re-started bus-errors arbit-lost error-warn error-pass bus-off
     0          0          0          0          0          0
     RX: bytes  packets  errors  dropped overrun mcast
     0          0        0       0       0       0
     TX: bytes  packets  errors  dropped carrier collsns
     0          0        0       0       0       0

ip link set can0 up type can bitrate 500000;
dmesg:
[ 1861.776977] cc770_isa cc770_isa.0: can0: setting BTR0=0x00 BTR1=0x1c
[ 1861.777102] cc770_isa cc770_isa.0: can0: Message object 15 for RX data, RTR, SFF and EFF
[ 1861.777118] cc770_isa cc770_isa.0: can0: Message object 11 for TX data, RTR, SFF and EFF

ip -d -s link show can0
6: can0: <NOARP,UP,LOWER_UP,ECHO> mtu 16 qdisc pfifo_fast state UNKNOWN qlen 10
     link/can
     can state ERROR-ACTIVE (berr-counter tx 128 rx 128) restart-ms 0
     bitrate 500000 sample-point 0.875
     tq 125 prop-seg 6 phase-seg1 7 phase-seg2 2 sjw 1
     cc770: tseg1 1..16 tseg2 1..8 sjw 1..4 brp 1..64 brp-inc 1
     clock 8000000
     re-started bus-errors arbit-lost error-warn error-pass bus-off
     0          0          0          0          0          0
     RX: bytes  packets  errors  dropped overrun mcast
     0          0        0       0       0       0
     TX: bytes  packets  errors  dropped carrier collsns
     1          0        0       0       0       0

PLC in unknown state
Unable to send and receive heartbeat
Rebooting PLC

ip -d -s link show can0
6: can0: <NOARP,UP,LOWER_UP,ECHO> mtu 16 qdisc pfifo_fast state UNKNOWN qlen 10
     link/can
     can state ERROR-ACTIVE (berr-counter tx 115 rx 0) restart-ms 0
     bitrate 500000 sample-point 0.875
     tq 125 prop-seg 6 phase-seg1 7 phase-seg2 2 sjw 1
     cc770: tseg1 1..16 tseg2 1..8 sjw 1..4 brp 1..64 brp-inc 1
     clock 8000000
     re-started bus-errors arbit-lost error-warn error-pass bus-off
     0          0          0          0          0          0
     RX: bytes  packets  errors  dropped overrun mcast
     0          0        0       0       0       0
     TX: bytes  packets  errors  dropped carrier collsns
     13         13       0       0       0       0

ip -d -s link show can0
6: can0: <NOARP,UP,LOWER_UP,ECHO> mtu 16 qdisc pfifo_fast state UNKNOWN qlen 10
     link/can
     can state ERROR-ACTIVE (berr-counter tx 107 rx 0) restart-ms 0
     bitrate 500000 sample-point 0.875
     tq 125 prop-seg 6 phase-seg1 7 phase-seg2 2 sjw 1
     cc770: tseg1 1..16 tseg2 1..8 sjw 1..4 brp 1..64 brp-inc 1
     clock 8000000
     re-started bus-errors arbit-lost error-warn error-pass bus-off
     0          0          0          0          0          0
     RX: bytes  packets  errors  dropped overrun mcast
     30         15       0       0       0       0
     TX: bytes  packets  errors  dropped carrier collsns
     21         21       0       0       0       0

dmesg:
[ 2102.085718] cc770_isa cc770_isa.0: can0: status interrupt (0x18)

ip -d -s link show can0
6: can0: <NOARP,UP,LOWER_UP,ECHO> mtu 16 qdisc pfifo_fast state UNKNOWN qlen 10
     link/can
     can state ERROR-ACTIVE (berr-counter tx 32 rx 0) restart-ms 0
     bitrate 500000 sample-point 0.875
     tq 125 prop-seg 6 phase-seg1 7 phase-seg2 2 sjw 1
     cc770: tseg1 1..16 tseg2 1..8 sjw 1..4 brp 1..64 brp-inc 1
     clock 8000000
     re-started bus-errors arbit-lost error-warn error-pass bus-off
     0          0          0          0          0          0
     RX: bytes  packets  errors  dropped overrun mcast
     310        156      0       0       0       0
     TX: bytes  packets  errors  dropped carrier collsns
     96         96       0       0       0       0

And with counters on zero:
ip -d -s link show can0
6: can0: <NOARP,UP,LOWER_UP,ECHO> mtu 16 qdisc pfifo_fast state UNKNOWN qlen 10
     link/can
     can state ERROR-ACTIVE (berr-counter tx 0 rx 0) restart-ms 0
     bitrate 500000 sample-point 0.875
     tq 125 prop-seg 6 phase-seg1 7 phase-seg2 2 sjw 1
     cc770: tseg1 1..16 tseg2 1..8 sjw 1..4 brp 1..64 brp-inc 1
     clock 8000000
     re-started bus-errors arbit-lost error-warn error-pass bus-off
     0          0          0          0          0          0
     RX: bytes  packets  errors  dropped overrun mcast
     358        204      0       0       0       0
     TX: bytes  packets  errors  dropped carrier collsns
     129        129      0       0       0       0


-----------------------------------------
Disconnecting cable for around 4 seconds:

dmesg:
[ 2339.660283] cc770_isa cc770_isa.0: can0: status interrupt (0x5b)

ip -d -s link show can0
6: can0: <NOARP,UP,LOWER_UP,ECHO> mtu 16 qdisc pfifo_fast state UNKNOWN qlen 10
     link/can
     can state ERROR-WARNING (berr-counter tx 128 rx 128) restart-ms 0
     bitrate 500000 sample-point 0.875
     tq 125 prop-seg 6 phase-seg1 7 phase-seg2 2 sjw 1
     cc770: tseg1 1..16 tseg2 1..8 sjw 1..4 brp 1..64 brp-inc 1
     clock 8000000
     re-started bus-errors arbit-lost error-warn error-pass bus-off
     0          0          0          1          0          0
     RX: bytes  packets  errors  dropped overrun mcast
     459        298      0       0       0       0
     TX: bytes  packets  errors  dropped carrier collsns
     193        192      0       0       0       0

Connecting again:
ip -d -s link show can0
6: can0: <NOARP,UP,LOWER_UP,ECHO> mtu 16 qdisc pfifo_fast state UNKNOWN qlen 10
     link/can
     can state ERROR-WARNING (berr-counter tx 120 rx 0) restart-ms 0
     bitrate 500000 sample-point 0.875
     tq 125 prop-seg 6 phase-seg1 7 phase-seg2 2 sjw 1
     cc770: tseg1 1..16 tseg2 1..8 sjw 1..4 brp 1..64 brp-inc 1
     clock 8000000
     re-started bus-errors arbit-lost error-warn error-pass bus-off
     0          0          0          1          0          0
     RX: bytes  packets  errors  dropped overrun mcast
     473        311      0       0       0       0
     TX: bytes  packets  errors  dropped carrier collsns
     200        200      0       0       0       0

After some time (around 125 seconds):
dmesg:
[ 2387.172008] cc770_isa cc770_isa.0: can0: status interrupt (0x18)
ip -d -s link show can0
6: can0: <NOARP,UP,LOWER_UP,ECHO> mtu 16 qdisc pfifo_fast state UNKNOWN qlen 10
     link/can
     can state ERROR-ACTIVE (berr-counter tx 29 rx 0) restart-ms 0
     bitrate 500000 sample-point 0.875
     tq 125 prop-seg 6 phase-seg1 7 phase-seg2 2 sjw 1
     cc770: tseg1 1..16 tseg2 1..8 sjw 1..4 brp 1..64 brp-inc 1
     clock 8000000
     re-started bus-errors arbit-lost error-warn error-pass bus-off
     0          0          0          1          0          0
     RX: bytes  packets  errors  dropped overrun mcast
     616        447      0       0       0       0
     TX: bytes  packets  errors  dropped carrier collsns
     291        291      0       0       0       0



-----------------------------------------
Disconnecting cable for around 55 seconds:

dmesg:
[ 2658.896959] cc770_isa cc770_isa.0: can0: status interrupt (0x5b)

ip -d -s link show can0
6: can0: <NOARP,UP,LOWER_UP,ECHO> mtu 16 qdisc pfifo_fast state UNKNOWN qlen 10
     link/can
     can state ERROR-WARNING (berr-counter tx 128 rx 128) restart-ms 0
     bitrate 500000 sample-point 0.875
     tq 125 prop-seg 6 phase-seg1 7 phase-seg2 2 sjw 1
     cc770: tseg1 1..16 tseg2 1..8 sjw 1..4 brp 1..64 brp-inc 1
     clock 8000000
     re-started bus-errors arbit-lost error-warn error-pass bus-off
     0          0          0          2          0          0
     RX: bytes  packets  errors  dropped overrun mcast
     797        621      0       0       0       0
     TX: bytes  packets  errors  dropped carrier collsns
     408        407      0       0       0       0




ip -d -s link show can0
6: can0: <NOARP,UP,LOWER_UP,ECHO> mtu 16 qdisc pfifo_fast state UNKNOWN qlen 10
     link/can
     can state ERROR-WARNING (berr-counter tx 112 rx 0) restart-ms 0
     bitrate 500000 sample-point 0.875
     tq 125 prop-seg 6 phase-seg1 7 phase-seg2 2 sjw 1
     cc770: tseg1 1..16 tseg2 1..8 sjw 1..4 brp 1..64 brp-inc 1
     clock 8000000
     re-started bus-errors arbit-lost error-warn error-pass bus-off
     0          0          0          2          0          0
     RX: bytes  packets  errors  dropped overrun mcast
     837        661      0       0       0       0
     TX: bytes  packets  errors  dropped carrier collsns
     423        423      0       0       0       0


dmesg:
[ 2765.805486] cc770_isa cc770_isa.0: can0: status interrupt (0x18)

ip -d -s link show can0
6: can0: <NOARP,UP,LOWER_UP,ECHO> mtu 16 qdisc pfifo_fast state UNKNOWN qlen 10
     link/can
     can state ERROR-ACTIVE (berr-counter tx 94 rx 0) restart-ms 0
     bitrate 500000 sample-point 0.875
     tq 125 prop-seg 6 phase-seg1 7 phase-seg2 2 sjw 1
     cc770: tseg1 1..16 tseg2 1..8 sjw 1..4 brp 1..64 brp-inc 1
     clock 8000000
     re-started bus-errors arbit-lost error-warn error-pass bus-off
     0          0          0          2          0          0
     RX: bytes  packets  errors  dropped overrun mcast
     872        689      0       0       0       0
     TX: bytes  packets  errors  dropped carrier collsns
     441        441      0       0       0       0




Thanks a lot.


Wolfgang
