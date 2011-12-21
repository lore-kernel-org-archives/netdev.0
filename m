From: Wolfgang Zarre <info-PyqsHJVlJN8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next v2 2/4] can: cc770: add
 legacy ISA bus driver for the CC770 and AN82527
Date: Wed, 21 Dec 2011 19:32:05 +0100
Message-ID: <4EF22625.5000109@essax.com>
References: <1322214204-1121-1-git-send-email-wg@grandegger.com>
	<1322214204-1121-3-git-send-email-wg@grandegger.com>
	<4ED0FEC5.3070108@hartkopp.net> <4ED34CAD.7040000@essax.com>
	<4ED351A8.8000102@grandegger.com> <4ED37885.8080909@essax.com>
	<4ED3B198.2040308@hartkopp.net> <4ED4A2EC.40103@grandegger.com>
	<4EDBC05D.8070109@essax.com> <4EDBC25D.50405@grandegger.com>
	<4EDE8435.5080100@essax.com> <4EDF6D54.2060503@grandegger.com>
	<4EE1E26B.6090308@grandegger.com> <4EE4F76E.3000506@essax.com>
	<4EE5C824.2050704@grandegger.com> <4EE5E321.8050104@essax.com>
	<4EE5EBBF.6080007@grandegger.com>
Reply-To: info-PyqsHJVlJN8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>, linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, socketcan-users-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-users-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4EE5EBBF.6080007-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
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

> On 12/12/2011 12:18 PM, Wolfgang Zarre wrote:
>> Hello Wolfgang,
>>> Hi Wolfgang,
>>>
>>> On 12/11/2011 07:33 PM, Wolfgang Zarre wrote:
>>>> Hello Wolfgang,
>>>>> On 12/07/2011 02:42 PM, Wolfgang Grandegger wrote:
>>>>>> Hi Wolfgang,
>>>>>>
>>>>>> On 12/06/2011 10:08 PM, Wolfgang Zarre wrote:
>>> ...
>>>>>>> Let me know if You need more or some other tests.
>>>>>>
>>>>>> You could provoke some state changes or bus-off conditions to see
>>>>>> if the
>>>>>> berr-counter shows reasonable results. I'm currently consolidating and
>>>>>> unifying error state and bus-off handling. Would be nice if you
>>>>>> could do
>>>>>> some further tests when I have the patches ready...
>>>>>
>>>>> I just pushed the mentioned modifications to the "devel" branch of my
>>>>> "wg-linux-can-next" [1] repository. You can get it as shown below:
>>>>>
>>>>>      $ git clone --reference=<some-recent-net-next-tree>    \
>>>>>
>>>>> git://gitorious.org/~wgrandegger/linux-can/wg-linux-can-next.git
>>>>>      $ git checkout -b devel devel
>>>>>
>>>>> [1] https://gitorious.org/~wgrandegger/linux-can/wg-linux-can-next
>>>>>
>>>>> Wolfgang.
>>>>
>>>> OK, I was trying so far and You will find below the results.
>>>> Just FYI the states on the PLC side couldn't be verified because the
>>>> function
>>>> provided by the manufacturer is not working at all and CAN analyser
>>>> was not
>>>> available.
>>>>
>>>> We are running CANopen and therefore the PLC will send automatically a
>>>> heartbeat.
>>>>
>>>> I produced the bus-off state through a short circuit between L/H
>>>> which was
>>>> working as expected.
>>>>
>>>> A bit odd was that on the second try I had to reload the module
>>>> because a ip down/up was not enough.
>>>
>>> Oops, not good.
>>>
>>
>> But might be in connection with the strange behaviour of the PLC.
>
> It's a bug! netif_start_queue is missing at the end of the open
> function. Got lost some how. I have just updated (rebased!) my
> wg-linux-can-next repository.

Ok, I was checking out last week and since I'm running one test series
after the other.

There are several odd issues I could found and I'm trying to trace them
down beside some other work.

Even with an assumed correct configuration like I was using with the lincan
driver I'm loosing telegrams so around 1 till 2 in 500000 but might be a
different sample-point at the PLC which is opaque due the predefined setting.
For the next test I'll set the BTR's directly.
Further sometimes I can find one in dropped but mostly not.

But more odd is that after an undefined time the transmission gets
stuck followed by a buffer overrun but can receive.
No error messages nor changes in ip -d -s link show can0.

Additional it seems that neither the automatic restart nor
the manual one works.

ip link set can0 up type can restart gives me 'RTNETLINK answers: Invalid
argument' and ip link set can0 up type can bitrate 500000 restart a
RTNETLINK answers: Device or resource busy but nothing connected to can0.

So I have to perform per example  ip link set can0 down;ip link set can0 up
type can bitrate 500000 restart-ms 2000 sample-point 0.75
but this is emptying the buffer and these telegrams are lost then as well.

I was comparing with my lincan driver which was running so far ok also
to confirm a proper working PLC.

First I assumed that maybe the set_reset_mode procedure is responsible for
that misbehaviour because according to the cc770 manual we should wait for
a zero of bit 7 RstST of the CPU interface register but when the transmission
gets stuck there was no call for set_reset_mode.

Maybe it's ending up somehow recessive.

Anyway, I might compare the registers of both drivers just to figure out
what's going on but maybe You have an idea as well.

Problem is just it runs always quite some time until the issues happen
otherwise it would be more easy.



>
> Wolfgang.


Wolfgang
