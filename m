From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [TG3]: About hw coalescing infrastructure.
Date: Mon, 04 Jul 2005 23:22:12 +0200
Message-ID: <42C9A884.1030906@cosmosbay.com>
References: <20050511.141530.57445142.davem@davemloft.net> <42B982D4.9040704@cosmosbay.com> <1119467012.5325.15.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Chan <mchan@broadcom.com>
In-Reply-To: <1119467012.5325.15.camel@rh4>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Michael Chan a =E9crit :
> On Wed, 2005-06-22 at 17:25 +0200, Eric Dumazet wrote:
>=20
>=20
>>Is there anything I can try to tune the coalescing ?
>>Being able to handle 100 packets each interrupt instead of one or two w=
ould certainly help.
>>I dont mind about latency. But of course I would like not to drop packe=
ts :)
>>But maybe the BCM5702 is not able to delay an interrupt ?
>>
>=20
>=20
> On the 5702 that supports CLRTCKS mode, you need to play around with th=
e
> following parameters in tg3.h. To reduce interrupts, you generally have
> to increase the values.
>=20
> #define  LOW_RXCOL_TICKS_CLRTCKS	 0x00000014
> #define  LOW_TXCOL_TICKS_CLRTCKS	 0x00000048
> #define  LOW_RXMAX_FRAMES		 0x00000005
> #define  LOW_TXMAX_FRAMES		 0x00000035
> #define  DEFAULT_RXCOAL_TICK_INT_CLRTCKS 0x00000014
> #define  DEFAULT_TXCOAL_TICK_INT_CLRTCKS 0x00000014
> #define  DEFAULT_RXCOAL_MAXF_INT	 0x00000005
> #define  DEFAULT_TXCOAL_MAXF_INT	 0x00000005
>=20
>=20
>=20

Thanks Michael

I tried various settings.

# ethtool -c eth0
Coalesce parameters for eth0:
Adaptive RX: off  TX: off
stats-block-usecs: 1000000
sample-interval: 0
pkt-rate-low: 0
pkt-rate-high: 0

rx-usecs: 500
rx-frames: 20
rx-usecs-irq: 500
rx-frames-irq: 20

tx-usecs: 600
tx-frames: 53
tx-usecs-irq: 600
tx-frames-irq: 20

rx-usecs-low: 0
rx-frame-low: 0
tx-usecs-low: 0
tx-frame-low: 0

rx-usecs-high: 0
rx-frame-high: 0
tx-usecs-high: 0
tx-frame-high: 0


But it seems something is wrong because when network load becomes high I =
get :

Jul  4 23:01:19 dada1 kernel: NETDEV WATCHDOG: eth0: transmit timed out
Jul  4 23:01:19 dada1 kernel: tg3: eth0: transmit timed out, resetting
Jul  4 23:01:24 dada1 kernel: NETDEV WATCHDOG: eth0: transmit timed out
Jul  4 23:01:24 dada1 kernel: tg3: eth0: transmit timed out, resetting
Jul  4 23:01:29 dada1 kernel: NETDEV WATCHDOG: eth0: transmit timed out
Jul  4 23:01:29 dada1 kernel: tg3: eth0: transmit timed out, resetting
Jul  4 23:01:34 dada1 kernel: NETDEV WATCHDOG: eth0: transmit timed out
Jul  4 23:01:34 dada1 kernel: tg3: eth0: transmit timed out, resetting
Jul  4 23:01:39 dada1 kernel: NETDEV WATCHDOG: eth0: transmit timed out
Jul  4 23:01:39 dada1 kernel: tg3: eth0: transmit timed out, resetting
Jul  4 23:01:44 dada1 kernel: NETDEV WATCHDOG: eth0: transmit timed out
Jul  4 23:01:44 dada1 kernel: tg3: eth0: transmit timed out, resetting
Jul  4 23:01:49 dada1 kernel: NETDEV WATCHDOG: eth0: transmit timed out
Jul  4 23:01:49 dada1 kernel: tg3: eth0: transmit timed out, resetting
Jul  4 23:01:54 dada1 kernel: NETDEV WATCHDOG: eth0: transmit timed out
Jul  4 23:01:54 dada1 kernel: tg3: eth0: transmit timed out, resetting
Jul  4 23:01:59 dada1 kernel: NETDEV WATCHDOG: eth0: transmit timed out
Jul  4 23:01:59 dada1 kernel: tg3: eth0: transmit timed out, resetting
Jul  4 23:02:04 dada1 kernel: NETDEV WATCHDOG: eth0: transmit timed out
Jul  4 23:02:04 dada1 kernel: tg3: eth0: transmit timed out, resetting
Jul  4 23:02:09 dada1 kernel: NETDEV WATCHDOG: eth0: transmit timed out
Jul  4 23:02:09 dada1 kernel: tg3: eth0: transmit timed out, resetting
Jul  4 23:02:14 dada1 kernel: NETDEV WATCHDOG: eth0: transmit timed out
Jul  4 23:02:14 dada1 kernel: tg3: eth0: transmit timed out, resetting
Jul  4 23:02:19 dada1 kernel: NETDEV WATCHDOG: eth0: transmit timed out
Jul  4 23:02:19 dada1 kernel: tg3: eth0: transmit timed out, resetting
Jul  4 23:02:24 dada1 kernel: NETDEV WATCHDOG: eth0: transmit timed out
Jul  4 23:02:24 dada1 kernel: tg3: eth0: transmit timed out, resetting
Jul  4 23:02:29 dada1 kernel: NETDEV WATCHDOG: eth0: transmit timed out
Jul  4 23:02:29 dada1 kernel: tg3: eth0: transmit timed out, resetting
Jul  4 23:02:34 dada1 kernel: NETDEV WATCHDOG: eth0: transmit timed out
Jul  4 23:02:34 dada1 kernel: tg3: eth0: transmit timed out, resetting
Jul  4 23:02:39 dada1 kernel: NETDEV WATCHDOG: eth0: transmit timed out
Jul  4 23:02:39 dada1 kernel: tg3: eth0: transmit timed out, resetting


Then the machine crashes at this point.

tg3.c :

#define DRV_MODULE_VERSION  "3.31"
#define DRV_MODULE_RELDATE  "June 8, 2005"

# ethtool -g eth0
Ring parameters for eth0:
Pre-set maximums:
RX:             511
RX Mini:        0
RX Jumbo:       255
TX:             0
Current hardware settings:
RX:             400
RX Mini:        0
RX Jumbo:       40
TX:             511


Thank you

Eric Dumazet
