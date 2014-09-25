From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [net-next PATCH 1/1 V4] qdisc: bulk dequeue support for qdiscs
 with TCQ_F_ONETXQUEUE
Date: Thu, 25 Sep 2014 06:52:21 -0700
Message-ID: <CAA93jw5qnx6M_p8cxKfOhMt2LYtkxzQXu8EHOktw_15+ZDCnig@mail.gmail.com>
References: <20140924160932.9721.56450.stgit@localhost>
	<20140924161047.9721.43080.stgit@localhost>
	<1411579395.15395.41.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140924195831.6fb91051@redhat.com>
	<54234225.5000503@mojatatu.com>
	<20140925102505.494acab1@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	=?UTF-8?B?VG9rZSBIw7hpbGFuZC1Kw7hyZ2Vuc2Vu?= <toke@toke.dk>,
	Florian Westphal <fw@strlen.de>,
	John Fastabend <john.r.fastabend@intel.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:41606 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751989AbaIYNwW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2014 09:52:22 -0400
Received: by mail-ob0-f181.google.com with SMTP id wo20so8390608obc.12
        for <netdev@vger.kernel.org>; Thu, 25 Sep 2014 06:52:21 -0700 (PDT)
In-Reply-To: <20140925102505.494acab1@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 25, 2014 at 1:25 AM, Jesper Dangaard Brouer
<brouer@redhat.com> wrote:
> On Wed, 24 Sep 2014 18:13:57 -0400
> Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>
>> On 09/24/14 13:58, Jesper Dangaard Brouer wrote:
>> > On Wed, 24 Sep 2014 10:23:15 -0700
>> > Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> >
>>
>> >
>> >> pktgen is nice, but do not represent the majority of the traffic =
we send
>> >> from high performance host where we want this bulk dequeue thing =
;)
>> >
>> > This patch is actually targetted towards more normal use-cases.
>> > Pktgen cannot even use this work, as it bypass the qdisc layer...
>>
>> When you post these patches - can you please also post basic perform=
ance
>> numbers? You dont have to show improvement if it is hard for bulking
>> to kick in, but you need to show no harm in at least latency for the
>> general use case (i.e not pktgen maybe forwarding activity or someth=
ing
>> sourced from tcp).
>
> I've done measurements with netperf-wrapper:
>  http://netoptimizer.blogspot.dk/2014/09/mini-tutorial-for-netperf-wr=
apper-setup.html
>
> I have already previously posted my measurements here:
>  http://people.netfilter.org/hawk/qdisc/
>  http://people.netfilter.org/hawk/qdisc/measure01/
>  http://people.netfilter.org/hawk/qdisc/experiment01/
>
> Please, see my previous mail where I described each graph.

Stuff like this:

http://people.netfilter.org/hawk/qdisc/experiment01/compare_TSO_vs_TSO_=
with_rxusec30__rr_latency.png

will no doubt make many a high speed trader happy.

My point being was that by repeating this experiment for each
successive change (eric's 1/2 BQL patch, better batching, sch_fq,
different ethernet drivers, etc),
you (or people duplicating the experiment) can produce
ongoing comparison plots...

> The above measurements is for 10Gbit/s, but I've also done measuremen=
ts
> on 1Gbit/s driver igb, and 10Mbit/s by forcing igb to use 10Mbit/s.
> Those results I forgot upload (and I cannot upload them right now, as
> I'm currently in Switzerland).
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
