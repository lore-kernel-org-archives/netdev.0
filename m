From: Wolfgang Zarre <info-PyqsHJVlJN8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next v2 2/4] can: cc770: add
 legacy ISA bus driver for the CC770 and AN82527
Date: Mon, 12 Dec 2011 12:18:57 +0100
Message-ID: <4EE5E321.8050104@essax.com>
References: <1322214204-1121-1-git-send-email-wg@grandegger.com>
	<1322214204-1121-3-git-send-email-wg@grandegger.com>
	<4ED0FEC5.3070108@hartkopp.net> <4ED34CAD.7040000@essax.com>
	<4ED351A8.8000102@grandegger.com> <4ED37885.8080909@essax.com>
	<4ED3B198.2040308@hartkopp.net> <4ED4A2EC.40103@grandegger.com>
	<4EDBC05D.8070109@essax.com> <4EDBC25D.50405@grandegger.com>
	<4EDE8435.5080100@essax.com> <4EDF6D54.2060503@grandegger.com>
	<4EE1E26B.6090308@grandegger.com> <4EE4F76E.3000506@essax.com>
	<4EE5C824.2050704@grandegger.com>
Reply-To: info-PyqsHJVlJN8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>, linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, socketcan-users-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-users-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4EE5C824.2050704-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
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

Hello Wolfgang,
> Hi Wolfgang,
>
> On 12/11/2011 07:33 PM, Wolfgang Zarre wrote:
>> Hello Wolfgang,
>>> On 12/07/2011 02:42 PM, Wolfgang Grandegger wrote:
>>>> Hi Wolfgang,
>>>>
>>>> On 12/06/2011 10:08 PM, Wolfgang Zarre wrote:
> ...
>>>>> Let me know if You need more or some other tests.
>>>>
>>>> You could provoke some state changes or bus-off conditions to see if the
>>>> berr-counter shows reasonable results. I'm currently consolidating and
>>>> unifying error state and bus-off handling. Would be nice if you could do
>>>> some further tests when I have the patches ready...
>>>
>>> I just pushed the mentioned modifications to the "devel" branch of my
>>> "wg-linux-can-next" [1] repository. You can get it as shown below:
>>>
>>>     $ git clone --reference=<some-recent-net-next-tree>   \
>>>         git://gitorious.org/~wgrandegger/linux-can/wg-linux-can-next.git
>>>     $ git checkout -b devel devel
>>>
>>> [1] https://gitorious.org/~wgrandegger/linux-can/wg-linux-can-next
>>>
>>> Wolfgang.
>>
>> OK, I was trying so far and You will find below the results.
>> Just FYI the states on the PLC side couldn't be verified because the
>> function
>> provided by the manufacturer is not working at all and CAN analyser was not
>> available.
>>
>> We are running CANopen and therefore the PLC will send automatically a
>> heartbeat.
>>
>> I produced the bus-off state through a short circuit between L/H which was
>> working as expected.
>>
>> A bit odd was that on the second try I had to reload the module
>> because a ip down/up was not enough.
>
> Oops, not good.
>

But might be in connection with the strange behaviour of the PLC.

>> Let me know if You would need further tests or different procedure.
>
> The state changes are reported via error messages, which you can list
> with "candump -td -e any,0:0,#FFFFFFFF" with the attached patch.
>

Thanks, I'll try this with the next series of tests.

>> Producing L/H short circuit for 2 seconds
>> dmesg:
>> [  885.409058] cc770_isa cc770_isa.0: can0: status interrupt (0x5b)
>> [  885.420475] cc770_isa cc770_isa.0: can0: status interrupt (0xc5)
>> [  885.420496] cc770_isa cc770_isa.0: can0: bus-off
>>
>> ip -d -s link show can0
>> 4: can0:<NO-CARRIER,NOARP,UP,ECHO>  mtu 16 qdisc pfifo_fast state DOWN
>> qlen 10
>>      link/can
>>      can state BUS-OFF (berr-counter tx 92 rx 103) restart-ms 0
>>      bitrate 500000 sample-point 0.875
>>      tq 125 prop-seg 6 phase-seg1 7 phase-seg2 2 sjw 1
>>      cc770: tseg1 1..16 tseg2 1..8 sjw 1..4 brp 1..64 brp-inc 1
>>      clock 8000000
>>      re-started bus-errors arbit-lost error-warn error-pass bus-off
>>      0          0          0          1          0          1
>>      RX: bytes  packets  errors  dropped overrun mcast
>>      544        382      0       0       0       0
>>      TX: bytes  packets  errors  dropped carrier collsns
>>      30         29       0       0       0       0
>>
>> Sending and receiving stops.
>>
>> Trying to recover on PC:
>> ip link set can0 down;
>> ip -d -s link show can0
>> 4: can0:<NOARP,ECHO>  mtu 16 qdisc pfifo_fast state DOWN qlen 10
>>      link/can
>>      can state STOPPED (berr-counter tx 92 rx 103) restart-ms 0
>>      bitrate 500000 sample-point 0.875
>>      tq 125 prop-seg 6 phase-seg1 7 phase-seg2 2 sjw 1
>>      cc770: tseg1 1..16 tseg2 1..8 sjw 1..4 brp 1..64 brp-inc 1
>>      clock 8000000
>>      re-started bus-errors arbit-lost error-warn error-pass bus-off
>>      0          0          0          1          0          1
>>      RX: bytes  packets  errors  dropped overrun mcast
>>      544        382      0       0       0       0
>>      TX: bytes  packets  errors  dropped carrier collsns
>>      30         29       0       1       0       0
>>
>> ip link set can0 up type can bitrate 500000;
>> dmesg:
>> [ 1090.937778] cc770_isa cc770_isa.0: can0: setting BTR0=0x00 BTR1=0x1c
>> [ 1090.937869] cc770_isa cc770_isa.0: can0: Message object 15 for RX
>> data, RTR, SFF and EFF
>> [ 1090.937885] cc770_isa cc770_isa.0: can0: Message object 11 for TX
>> data, RTR, SFF and EFF
>> [ 1090.938050] ADDRCONF(NETDEV_CHANGE): can0: link becomes ready
>> [ 1090.940769] cc770_isa cc770_isa.0: can0: status interrupt (0x5)
>>
>> ip -d -s link show can0
>> 4: can0:<NOARP,UP,LOWER_UP,ECHO>  mtu 16 qdisc pfifo_fast state UP qlen 10
>>      link/can
>>      can state ERROR-ACTIVE (berr-counter tx 0 rx 0) restart-ms 0
>>      bitrate 500000 sample-point 0.875
>>      tq 125 prop-seg 6 phase-seg1 7 phase-seg2 2 sjw 1
>>      cc770: tseg1 1..16 tseg2 1..8 sjw 1..4 brp 1..64 brp-inc 1
>>      clock 8000000
>>      re-started bus-errors arbit-lost error-warn error-pass bus-off
>>      0          0          0          1          0          1
>>      RX: bytes  packets  errors  dropped overrun mcast
>>      552        383      0       0       0       0
>>      TX: bytes  packets  errors  dropped carrier collsns
>>      30         29       0       1       0       0
>>
>> PLC in unknown state but not sending heartbeat,
>> Rebooting PLC
>
> Hm, does it work if you do the bus-off recovery manually with?
>
>    # ip link set can0 up type can restart
>
> ... or automatically with?
>
>    # ip link set can0 up type can restart-ms 5000

Ah, ok, good point, will try out as well with the next series of tests

>
> Anyway, rebooting/reloading should never be necessary. I will check on
> my i82572.
>
>> -----------------------------------------
>> Disconnecting cable for around 4 seconds:
>>
>> dmesg:
>> [ 2339.660283] cc770_isa cc770_isa.0: can0: status interrupt (0x5b)
>>
>> ip -d -s link show can0
>> 6: can0:<NOARP,UP,LOWER_UP,ECHO>  mtu 16 qdisc pfifo_fast state UNKNOWN
>> qlen 10
>>      link/can
>>      can state ERROR-WARNING (berr-counter tx 128 rx 128) restart-ms 0
>>      bitrate 500000 sample-point 0.875
>>      tq 125 prop-seg 6 phase-seg1 7 phase-seg2 2 sjw 1
>>      cc770: tseg1 1..16 tseg2 1..8 sjw 1..4 brp 1..64 brp-inc 1
>>      clock 8000000
>>      re-started bus-errors arbit-lost error-warn error-pass bus-off
>>      0          0          0          1          0          0
>>      RX: bytes  packets  errors  dropped overrun mcast
>>      459        298      0       0       0       0
>>      TX: bytes  packets  errors  dropped carrier collsns
>>      193        192      0       0       0       0
>
> TX and RX berr-counter are>= 128. I wonder why error passive was not
> reached.

Hmmm, that is a good question and You are right > 127 should be error-passive,
anyway, just realised now, what means then 'error-warning' because I just
know error-active, error-passive and bus-off.

>
>> Connecting again:
>> ip -d -s link show can0
>> 6: can0:<NOARP,UP,LOWER_UP,ECHO>  mtu 16 qdisc pfifo_fast state UNKNOWN
>> qlen 10
>>      link/can
>>      can state ERROR-WARNING (berr-counter tx 120 rx 0) restart-ms 0
>>      bitrate 500000 sample-point 0.875
>>      tq 125 prop-seg 6 phase-seg1 7 phase-seg2 2 sjw 1
>>      cc770: tseg1 1..16 tseg2 1..8 sjw 1..4 brp 1..64 brp-inc 1
>>      clock 8000000
>>      re-started bus-errors arbit-lost error-warn error-pass bus-off
>>      0          0          0          1          0          0
>>      RX: bytes  packets  errors  dropped overrun mcast
>>      473        311      0       0       0       0
>>      TX: bytes  packets  errors  dropped carrier collsns
>>      200        200      0       0       0       0
>>
>> After some time (around 125 seconds):
>> dmesg:
>> [ 2387.172008] cc770_isa cc770_isa.0: can0: status interrupt (0x18)
>> ip -d -s link show can0
>> 6: can0:<NOARP,UP,LOWER_UP,ECHO>  mtu 16 qdisc pfifo_fast state UNKNOWN
>> qlen 10
>>      link/can
>>      can state ERROR-ACTIVE (berr-counter tx 29 rx 0) restart-ms 0
>>      bitrate 500000 sample-point 0.875
>>      tq 125 prop-seg 6 phase-seg1 7 phase-seg2 2 sjw 1
>>      cc770: tseg1 1..16 tseg2 1..8 sjw 1..4 brp 1..64 brp-inc 1
>>      clock 8000000
>>      re-started bus-errors arbit-lost error-warn error-pass bus-off
>>      0          0          0          1          0          0
>>      RX: bytes  packets  errors  dropped overrun mcast
>>      616        447      0       0       0       0
>>      TX: bytes  packets  errors  dropped carrier collsns
>>      291        291      0       0       0       0
>
> OK, the state is back to error active (counter<  96).
>
> Thanks for testing...

You are welcome, however, I have to thank You for Your work done.

So, I'll try as soon as I can another series of tests and may be
You let me know if You have patches I should include as well.

>
> Wolfgang.
>
>
>

Thanks

Wolfgang
