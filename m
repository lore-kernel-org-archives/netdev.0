From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: questions on NAPI processing latency and dropped network packets
Date: Tue, 22 Jan 2008 06:46:45 +0100
Message-ID: <47958345.7070807@cosmosbay.com>
References: <478654C3.60806@nortel.com> <4794F848.9020402@nortel.com> <47950F1D.4010508@cosmosbay.com> <479529DF.5030707@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Chris Friesen <cfriesen@nortel.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758223AbYAVFww@vger.kernel.org>
In-Reply-To: <479529DF.5030707@nortel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chris Friesen a =E9crit :
> Eric Dumazet wrote:
>> Chris Friesen a =E9crit :
>>
>>> I've done some further digging, and it appears that one of the=20
>>> problems we may be facing is very high instantaneous traffic rates.
>>>
>>> Instrumentation showed up to 222K packets/sec for short periods (at=
=20
>>> least 1.1 ms, possibly longer), although the long-term average is=20
>>> down around 14-16K packets/sec.
>>
>>
>> Instrumentation done where exactly ?
>=20
> I added some code to e1000_clean_rx_irq() to track rx_fifo drops, tot=
al=20
> packets received, and an accurate timestamp.
>=20
> If rx_fifo errors changed, it would dump the information.
>=20
>>> Is there anything else we can do to minimize the latency of network=
=20
>>> packet processing and avoid having to crank the rx ring size up so =
high?
>=20
>> You have some tasks that disable softirqs too long. Sometimes, bumpi=
ng=20
>> RX ring size is OK (but you will still have delays), sometimes it is=
=20
>> not an option, since 4096 is the limit on current hardware.
>=20
> I added some instrumentation to take timestamps in __do_softirq() as=20
> well.  Based on these timestamps, I can see the following code sequen=
ce:
>=20
> 2374604616 usec, start processing softirqs in __do_softirq()
> 2374610337 usec, log values in e1000_clean_rx_irq()
> 2374611411 usec, log values in e1000_clean_rx_irq()
>=20
> In between the successive calls to e1000_clean_rx_irq() the rx_fifo=20
> counts went up.
>=20
> Does anyone have any patchsets to track down what softirqs are taking=
 a=20
> long time, and/or who's disabling softirqs?
>=20

Not for linux-2.6.10 unfortunatly.

Check net/ipv4/route.c, where many improvements can be done, especially=
 if you=20
have a large rt cache

grep . /proc/sys/net/ipv4/route/*
