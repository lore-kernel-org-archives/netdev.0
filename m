From: apetlund@simula.no
Subject: Re: [PATCH 2/3] net: TCP thin linear timeouts
Date: Thu, 29 Oct 2009 16:19:33 +0100
Message-ID: <83449a990112ea3cf5f172e7f6ee9874.squirrel@webmail.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Eric Dumazet" <eric.dumazet@gmail.com>,
	"Andreas Petlund" <apetlund@simula.no>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, shemminger@vyatta.com,
	ilpo.jarvinen@helsinki.fi, davem@davemloft.net
To: "Arnd Hannemann" <hannemann@nets.rwth-aachen.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755226AbZJ2PTb@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I apologise that some of you received this mail more than once. My emai=
l
client played a HTML-trick on me.

> Eric Dumazet schrieb:
>> Andreas Petlund a =E9crit :
>>> This patch will make TCP use only linear timeouts if the stream is
thin. This will help to avoid the very high latencies that thin stream
suffer because of exponential backoff. This mechanism is only active
if
>>> enabled by iocontrol or syscontrol and the stream is identified as =
thin.
>> Wont this reduce the session timeout to something very small, ie 15
retransmits, way under the minute ?
>
> The session timeout no longer depends on the actual number of
retransmits.
> Instead its a time interval,
> which is roughly equivalent to the time a TCP, performing exponential
backoff would need to perform
> 15 retransmits.
>
> However, addressing the proposal:
> I wonder how one can seriously suggest to just skip congestion respon=
se
during timeout-based
> loss recovery? I believe that in a heavily congested scenarios, this
would
> lead to a goodput
> goodput disaster... Not to mention that in a heavily congested scenar=
io,
suddenly every flow
> will become "thin", so this will even amplify the problems. Or did I
miss
> something?

We have found no noticeable degradation of the goodput in a series of
experiments we have performed in order to map the effects of the
modifications. Furthermore, the modifications implemented in the patche=
s
are explicitly enabled only for applications where the developer knows
that streams will be thin, thus only a small subset of the streams will
apply the modifications.

Graphs presenting results from experiments performed to analyse latency
and fairness issues can be found here:
http://folk.uio.no/apetlund/lktmp/

-AP
