From: Dave Taht <dave.taht@gmail.com>
Subject: Re: Network optimality (was Re: [PATCH net-next] qdisc: validate skb
 without holding lock_
Date: Mon, 13 Oct 2014 13:47:14 -0700
Message-ID: <CAA93jw7Q4+NqvsShEUG7b2Nu8F8dFMsesZZTFg=npAtfxKhOmg@mail.gmail.com>
References: <CAA93jw58cBPToe7oL6YH-178n2jg+qh5GYJW7Ww9NHgcb5QPnA@mail.gmail.com>
	<CAL4WiioOodM60_Ud6qyGt1_uyeqpDeGFF6PtEKtGa=NwHhVFiw@mail.gmail.com>
	<1413219532.9362.109.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAA93jw5MKVaNaObVD3Lm=DP0ie6HcjwOvt0X-whDLJD_6hF5bw@mail.gmail.com>
	<20141013222717.42f3c399@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Florian Westphal <fw@strlen.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	=?UTF-8?B?VG9rZSBIw7hpbGFuZC1Kw7hyZ2Vuc2Vu?= <toke@toke.dk>,
	Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f44.google.com ([209.85.218.44]:54259 "EHLO
	mail-oi0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751188AbaJMUrP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2014 16:47:15 -0400
Received: by mail-oi0-f44.google.com with SMTP id x69so14460089oia.17
        for <netdev@vger.kernel.org>; Mon, 13 Oct 2014 13:47:14 -0700 (PDT)
In-Reply-To: <20141013222717.42f3c399@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 13, 2014 at 1:27 PM, Jesper Dangaard Brouer
<brouer@redhat.com> wrote:
>
> On Mon, 13 Oct 2014 10:20:17 -0700 Dave Taht <dave.taht@gmail.com> wr=
ote:
>
>> On Mon, Oct 13, 2014 at 9:58 AM, Eric Dumazet <eric.dumazet@gmail.co=
m> wrote:
>> >
>> >> On Oct 13, 2014 7:22 AM, "Dave Taht" <dave.taht@gmail.com> wrote:
> [...]
>>
>> I would like to also get better behavior out of gigE and below, and =
for
>> these changes to not impact the downstream behavior of the network
>> overall.
>
> I also care about 1Gbit/s and below, that why I did some many tests
> (with igb at 10Mbit/s, 100Mbit/s and 1Gbit/s).
>
>
>> To give you an example, I would like to see the tcp flows in the
>> 2nd chart here, to converge faster than the 5 seconds they currently
>> take at GigE speeds.
>>
>> http://snapon.lab.bufferbloat.net/~cero2/nuc-to-puck/results.html
>
> In the last graph, where you cannot saturate the link, because you
> turned off GSO, GRO and TSO.  Here I expect you will see the benefit =
of
> the qdisc bulking. That is, will be able to saturate the link and
> achieve the lower latency as BQL will cut off the bursts at +1 MTU.
> I would be interested in the results...

I am too!!!! 5 seconds to converge? 50x the baseline latency when under=
 load?
vs not being able to saturate the link at all? Ugh. Two lousy choices.

I think xmit_more will
help a lot in the latter case, my other suggestions regarding reducing
the size of the offloads in the former.

But it looks like xmit_more support needs to be added to fq, and fq_cod=
el (?),
and despite me reading the patches submitted thus far, it would be sane=
r
for someone else to patch e1000e support for the nuc (and the zillions
of other e1000e platforms)

(did I miss that patch go by?)

I'm certainly willing to test the result on that platform (and I have
some other tweaks
in my queue at the qdisc layer that I can throw in, also).

>> > We made all these changes so that we can spend cpu cycles at the r=
ight
>> > place.
>
> Exactly.

+1.

So what happens when more cpu cycles are available in the right place?

The dequeue routines in both fq and fq_codel are a bit more complex tha=
n
pfifo_fast (and I've longed to kill the maxpacket concept in codel, btw=
)....

y'all are in such a lovely place with profilers and hardware at the rea=
dy
to just make a simple sysctl and analyze what happens at rates I can
only dream of.


>
> --
> Best regards,
>   Jesper Dangaard Brouer
>   MSc.CS, Sr. Network Kernel Developer at Red Hat
>   Author of http://www.iptv-analyzer.org
>   LinkedIn: http://www.linkedin.com/in/brouer



--=20
Dave T=C3=A4ht

https://www.bufferbloat.net/projects/make-wifi-fast
