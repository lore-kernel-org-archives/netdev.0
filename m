From: Bradley Peterson <despite@gmail.com>
Subject: Re: Single core gets pegged on multi-core PPTP server
Date: Fri, 20 Jan 2012 09:20:02 -0600
Message-ID: <CAJuWrdu13Usax+bD3gtOkK=dhFyHQfMk5E7CLM=q8j_u92Hfkg@mail.gmail.com>
References: <CAJuWrdtDgeCOSEvD-ytfwGj4UQeOtjeqUZd3Y1SLpbbsSvrycg@mail.gmail.com>
	<1327040190.4826.7.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: paulus@samba.org, linux-ppp@vger.kernel.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <1327040190.4826.7.camel@edumazet-laptop>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 20, 2012 at 12:16 AM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> Le jeudi 19 janvier 2012 =E0 16:35 -0600, Bradley Peterson a =E9crit =
:
>> Hello,
>>
>> I am trying to test the capacity of a linux PPTP server, both in
>> number of connections, and in packets per second. =A0I am using kern=
el
>> 2.6.38.8, with the ppp, pptp, and gre modules, and accel-pptp 0.8.3.
>> I have RPS, RFS, and XPS enabled on the network devices for SMP
>> support.
>>
>> But I'm seeing one CPU get pegged out with soft interrupt, while the
>> others are almost completely idle.
>>
>> In my current test, I'm starting 250 pptp connections from another
>> server, then running iperf across each connection. =A0The client mac=
hine
>> pegs out, sure, but I'm surprised the server pegs out a single CPU.
>> With RPS, I would expect softirq's to be more balanced.
>>
>> Where could the bottleneck be? =A0Do all ppp packets need to be
>> processed serially?
>>
>
> Hmmm, you need a more recent kernel or backport commit
> c6865cb3cc6f3c2857fa4c6f5fda2945d70b1e84
> =A0 =A0rps: Inspect GRE encapsulated packets to get flow hash
>
> =A0 =A0Crack open GRE packets in __skb_get_rxhash to compute 4-tuple =
hash on
> =A0 =A0in encapsulated packet. =A0Note that this is used only when th=
e
> =A0 =A0__skb_get_rxhash is taken, in particular only when the device =
does
> =A0 =A0not compute provide the rxhash (ie. feature is disabled).
>
> =A0 =A0This was tested by creating a single GRE tunnel between two 16=
 core
> =A0 =A0AMD machines. =A0200 netperf TCP_RR streams were ran with 1 by=
te
> =A0 =A0request and response size.
>
> =A0 =A0Without patch: 157497 tps, 50/90/99% latencies 1250/1292/1364 =
usecs
> =A0 =A0With patch: 325896 tps, 50/90/99% latencies 603/848/1169
>
> =A0 =A0Signed-off-by: Tom Herbert <therbert@google.com>
> =A0 =A0Signed-off-by: David S. Miller <davem@davemloft.net>
>
>
>
> And make sure you disabled hardware rxhash (if your NIC provides it)
>
>

Thank you, I had missed the work on RPS with encapsulated packets.  I
will try a newer kernel.
