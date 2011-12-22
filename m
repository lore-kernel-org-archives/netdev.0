From: Wolfgang Zarre <info-PyqsHJVlJN8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next v2 2/4] can: cc770: add
 legacy ISA bus driver for the CC770 and AN82527
Date: Thu, 22 Dec 2011 14:20:04 +0100
Message-ID: <4EF32E84.1080006@essax.com>
References: <1322214204-1121-1-git-send-email-wg@grandegger.com>
	<1322214204-1121-3-git-send-email-wg@grandegger.com>
	<4ED0FEC5.3070108@hartkopp.net> <4ED34CAD.7040000@essax.com>
	<4ED351A8.8000102@grandegger.com> <4ED37885.8080909@essax.com>
	<4ED3B198.2040308@hartkopp.net> <4ED4A2EC.40103@grandegger.com>
	<4EDBC05D.8070109@essax.com> <4EDBC25D.50405@grandegger.com>
	<4EDE8435.5080100@essax.com> <4EDF6D54.2060503@grandegger.com>
	<4EE1E26B.6090308@grandegger.com> <4EE4F76E.3000506@essax.com>
	<4EE5C824.2050704@grandegger.com> <4EE5E321.8050104@essax.com>
	<4EE5EBBF.6080007@grandegger.com> <4EF22625.5000109@essax.com>
	<4EF2FA3F.3010308@grandegger.com>
Reply-To: info-PyqsHJVlJN8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>, linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, socketcan-users-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-users-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4EF2FA3F.3010308-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
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
> On 12/21/2011 07:32 PM, Wolfgang Zarre wrote:
>> Hello Wolfgang,
> ...
>
>>> It's a bug! netif_start_queue is missing at the end of the open
>>> function. Got lost some how. I have just updated (rebased!) my
>>> wg-linux-can-next repository.
>>
>> Ok, I was checking out last week and since I'm running one test series
>> after the other.
>>
>> There are several odd issues I could found and I'm trying to trace them
>> down beside some other work.
>>
>> Even with an assumed correct configuration like I was using with the lincan
>> driver I'm loosing telegrams so around 1 till 2 in 500000 but might be a
>> different sample-point at the PLC which is opaque due the predefined
>> setting.
>
> In principle, messages can be lost because the cc770 does buffer only up
> to two messages in hardware. If they are not read out quickly enough,
> message loss will happen. The CAN statistics should list such overruns,
> though.
>
Actually I loose them on transmission, not reception, but as mentioned
one time we traced with a second PC and there the telegrams are not lost
which means they are really going over the bus physically.
So maybe just a timing issue but for now secondary.

However the telegrams are sent with 5ms space parallel to the heartbeat.

>> For the next test I'll set the BTR's directly.
>
> OK, if you do not see bus errors, everything should be fine.
>

The test with BTR's set was not working out due the fact that
the software for coding the PLC doesn't allow, I'm loving it.

>> Further sometimes I can find one in dropped but mostly not.
>>
>> But more odd is that after an undefined time the transmission gets
>> stuck followed by a buffer overrun but can receive.
>
> I recently found a bug. Please try this fix:
>
> http://marc.info/?l=linux-can&m=132370253713701&w=4

The fix is already included as checked out.

>
> Did you realize related error messages in the dmesg output?

Nothing at all, as mentioned .

>
>> No error messages nor changes in ip -d -s link show can0.
>>
>> Additional it seems that neither the automatic restart nor
>> the manual one works.
>
> What version are you using. I think this problem has been fixed by
> adding the missing netif_start_queue() at the end of the open
> function, as mentioned above. Do you have that in your driver?
>

Yes, is already included as well, I'm using commit
eec921ac28fde243456078a557768808d93d94a3


>> ip link set can0 up type can restart gives me 'RTNETLINK answers: Invalid
>> argument' and ip link set can0 up type can bitrate 500000 restart a
>> RTNETLINK answers: Device or resource busy but nothing connected to can0.
>
> The error message is shown because you try to set bitrate when the
> device is up. For the restart after bus-off just type:
>
>    # ip link set can0 type can restart

Actually I tried it when it's get stuck but is anyway a hint that
the device is still up,

>
> Anyway, if you run into a bus-off, then it's likely that you have
> electrical problems on the CAN bus, e.g. termination, mismatching
> bit-timing parameters.

As said I have no indication of any kind of problem:
5: can0: <NOARP,UP,LOWER_UP,ECHO> mtu 16 qdisc pfifo_fast state UNKNOWN qlen 10
     link/can
     can state ERROR-ACTIVE (berr-counter tx 0 rx 0) restart-ms 2000
     bitrate 500000 sample-point 0.750
     tq 125 prop-seg 5 phase-seg1 6 phase-seg2 4 sjw 1
     cc770: tseg1 1..16 tseg2 1..8 sjw 1..4 brp 1..64 brp-inc 1
     clock 16000000
     re-started bus-errors arbit-lost error-warn error-pass bus-off
     0          0          0          0          0          0
     RX: bytes  packets  errors  dropped overrun mcast
     76506      74616    0       0       0       0
     TX: bytes  packets  errors  dropped carrier collsns
     2450703    616355   0       0       0       0

>
>> So I have to perform per example  ip link set can0 down;ip link set can0 up
>> type can bitrate 500000 restart-ms 2000 sample-point 0.75
>> but this is emptying the buffer and these telegrams are lost then as well.
>>
>> I was comparing with my lincan driver which was running so far ok also
>> to confirm a proper working PLC.
>>
>> First I assumed that maybe the set_reset_mode procedure is responsible for
>> that misbehaviour because according to the cc770 manual we should wait for
>> a zero of bit 7 RstST of the CPU interface register but when the
>> transmission
>> gets stuck there was no call for set_reset_mode.
>>
>> Maybe it's ending up somehow recessive.
>>
>> Anyway, I might compare the registers of both drivers just to figure out
>> what's going on but maybe You have an idea as well.
>>
>> Problem is just it runs always quite some time until the issues happen
>> otherwise it would be more easy.
>
> Again, please check if you have netif_start_queue() at the end of the
> open function.
>

As said I'm using eec921ac28fde243456078a557768808d93d94a3

However, I'll try further to investigate that issue due the fact having it
running with my lincan without problems and therefore it should be possible
to find the problem.

> Wolfgang.

Wolfgang
