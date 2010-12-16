From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: Re: Possible regression: Packet drops during iptables calls
Date: Thu, 16 Dec 2010 15:24:49 +0100
Message-ID: <1292509489.31289.20.camel@firesoul.comx.local>
References: <1292337974.9155.68.camel@firesoul.comx.local>
	 <1292340702.5934.5.camel@edumazet-laptop>
	 <1292342958.9155.91.camel@firesoul.comx.local>
	 <1292343855.5934.27.camel@edumazet-laptop>
	 <1292508266.31289.12.camel@firesoul.comx.local>
	 <1292508733.2883.152.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arnaldo Carvalho de Melo <acme@infradead.org>,
	Steven Rostedt <srostedt@redhat.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1292508733.2883.152.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-12-16 at 15:12 +0100, Eric Dumazet wrote:
> Le jeudi 16 d=C3=A9cembre 2010 =C3=A0 15:04 +0100, Jesper Dangaard Br=
ouer a

> > The vmalloc size is approx 19 MB (19.820.544 bytes) (see
> > /proc/vmallocinfo).  Looking through vmallocinfo I realized that
> > even-though I only have 16 CPUs, there is 32 allocated rulesets
> > "xt_alloc_table_info" (for the filter table). Thus, I have approx
> > 634MB iptables filter rules in the kernel, half of which is totally
> > unused.
>=20
> Boot your machine with : "maxcpus=3D16 possible_cpus=3D16", it will b=
e much
> better ;)

Good, trick.  I'll use that.

> > Guess this is because we use: "for_each_possible_cpu" instead of
> > "for_each_online_cpu". (Feel free to fix this, or point me to some
> > documentation of this CPU hotplug stuff... I see we are missing
> > get_cpu() and put_cpu() a lot of places).
>=20
> Are you really using cpu hotplug ? If not, the "maxcpus=3D16
> possible_cpus=3D16" trick should be enough for you.

No, not using hotplug CPUs.  Its just a pitty that we waste kernel
memory on this, for every one which does not know the "maxcpus=3D16
possible_cpus=3D16" trick...

But as I don't have a hotplug CPU system, I have no chance of testing a=
n
eventual code fix/patch.


> >=20
>=20
> In order to accelerate, you could eventually pre-fill cpu cache befor=
e
> the local_bh_disable() (just reading the table). So that critical
> section is short, because mostly in your cpu cache.

In my case I think this will not help. I'll kill the cache anyways, as
the ruleset is 19MB and my CPU cache is 8MB.


--=20
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network Kernel Developer
  Cand. Scient Datalog / MSc.CS
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
