From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: questions on NAPI processing latency and dropped network packets
Date: Mon, 21 Jan 2008 17:25:19 -0600
Message-ID: <479529DF.5030707@nortel.com>
References: <478654C3.60806@nortel.com> <4794F848.9020402@nortel.com> <47950F1D.4010508@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zcars04e.nortel.com ([47.129.242.56]:51304 "EHLO
	zcars04e.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756842AbYAUXZx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2008 18:25:53 -0500
In-Reply-To: <47950F1D.4010508@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Chris Friesen a =E9crit :
>=20
>> I've done some further digging, and it appears that one of the=20
>> problems we may be facing is very high instantaneous traffic rates.
>>
>> Instrumentation showed up to 222K packets/sec for short periods (at=20
>> least 1.1 ms, possibly longer), although the long-term average is do=
wn=20
>> around 14-16K packets/sec.
>=20
>=20
> Instrumentation done where exactly ?

I added some code to e1000_clean_rx_irq() to track rx_fifo drops, total=
=20
packets received, and an accurate timestamp.

If rx_fifo errors changed, it would dump the information.

>> Is there anything else we can do to minimize the latency of network=20
>> packet processing and avoid having to crank the rx ring size up so h=
igh?

> You have some tasks that disable softirqs too long. Sometimes, bumpin=
g=20
> RX ring size is OK (but you will still have delays), sometimes it is =
not=20
> an option, since 4096 is the limit on current hardware.

I added some instrumentation to take timestamps in __do_softirq() as=20
well.  Based on these timestamps, I can see the following code sequence=
:

2374604616 usec, start processing softirqs in __do_softirq()
2374610337 usec, log values in e1000_clean_rx_irq()
2374611411 usec, log values in e1000_clean_rx_irq()

In between the successive calls to e1000_clean_rx_irq() the rx_fifo=20
counts went up.

Does anyone have any patchsets to track down what softirqs are taking a=
=20
long time, and/or who's disabling softirqs?

Chris
