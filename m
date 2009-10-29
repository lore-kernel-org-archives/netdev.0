From: apetlund@simula.no
Subject: Re: [PATCH 2/3] net: TCP thin linear timeouts
Date: Thu, 29 Oct 2009 16:43:34 +0100
Message-ID: <69812160e5682c9fb4acba05bc082664.squirrel@webmail.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Andreas Petlund" <apetlund@simula.no>,
	Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	"Arnd Hannemann" <hannemann@nets.rwth-aachen.de>,
	"Netdev" <netdev@vger.kernel.org>,
	"LKML" <linux-kernel@vger.kernel.org>, shemminger@vyatta.com,
	"David Miller" <davem@davemloft.net>
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755378AbZJ2Pne@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Andreas Petlund a =E9crit :
>
>> The removal of exponential backoff on a general basis has been
>> investigated and discussed already, for instance here:
>> http://ccr.sigcomm.org/online/?q=3Dnode/416
>> Such steps are, however considered drastic, and I agree that caution
must be made to thoroughly investigate the effects of such changes. The
changes introduced by the proposed patches, however, are not
default
>> behaviour, but an option for applications that suffer from the
>> thin-stream TCP increased retransmission latencies. They will, as su=
ch,
not affect all streams. In addition, the changes will only be active
for
>> streams which are perpetually thin or in the early phase of expandin=
g
their cwnd. Also, experiments performed on congested bottlenecks with
tail-drop queues show very little (if any at all) effect on goodput for
the modified scenario compared to a scenario with unmodified TCP
streams.
>> Graphs both for latency-results and fairness tests can be found here=
:
http://folk.uio.no/apetlund/lktmp/
>
> There should be a limit to linear timeouts, to say ... no more than 6
retransmits
> (eventually tunable), then switch to exponential backoff. Maybe your
patch
> already implement such heuristic ?
>

The limitation you suggest to the linear timeouts makes very good sense=
=2E
Our experiments performed on the Internet indicate that it is extremely
rare that more than 6 retransmissions are needed to recover. It is not
included in the current patch, so I will include this in the next
iteration.

> True link collapses do happen, it would be good if not all streams
wakeup
> in the same
> second and make recovery very slow.
>

Each stream will have its own schedule for wakeup, so such events will
still be subject to coincidence. The timer granularity of the TCP wakeu=
p
timer will also influence how many streams will wake at the same time. =
The
experiments we have performed on severely congested bottlenecks (link
above) indicate that the modifications will not create a large negative
effect. In fact, when goodput is drastically reduced due to severe
overload, regular TCP and the LT and dupACK modifications seem to perfo=
rm
nearly identically. Other scenarios may exist where different effects c=
an
be observed, and I am open to suggestions for further testing.

> Thats too easy to accept possibly dangerous features with the excuse =
of
saying
> "It wont be used very much", because you cannot predict the future.

I agree that it is no argument to say that it won't be used much; indee=
d,
my hope is that it will be used much. However, our experiments indicate=
 no
negative effects while showing a large improvement on retransmission
latency for the scenario in question. I therefore think that the option
for such an improvement should be made available for time-dependent
thin-stream applications.

-AP
