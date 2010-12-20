From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4 net-next-2.6] netfilter: x_tables: dont block BH
 while reading counters
Date: Mon, 20 Dec 2010 15:45:46 +0100
Message-ID: <1292856346.2800.54.camel@edumazet-laptop>
References: <1292337974.9155.68.camel@firesoul.comx.local>
	 <1292340702.5934.5.camel@edumazet-laptop>
	 <1292342958.9155.91.camel@firesoul.comx.local>
	 <1292343855.5934.27.camel@edumazet-laptop>
	 <1292508266.31289.12.camel@firesoul.comx.local>
	 <1292508733.2883.152.camel@edumazet-laptop>
	 <1292509489.31289.20.camel@firesoul.comx.local>
	 <1292509775.2883.187.camel@edumazet-laptop>
	 <1292511761.2883.236.camel@edumazet-laptop>
	 <1292515625.2883.336.camel@edumazet-laptop>
	 <1292518436.2883.393.camel@edumazet-laptop>
	 <20101216093149.71f082c7@nehalam>
	 <1292521986.2883.472.camel@edumazet-laptop>
	 <1292646579.7894.42.camel@edumazet-laptop>
	 <1292852541.31289.75.camel@firesoul.comx.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Jesper Dangaard Brouer <hawk@comx.dk>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1292852541.31289.75.camel@firesoul.comx.local>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 20 d=C3=A9cembre 2010 =C3=A0 14:42 +0100, Jesper Dangaard Brou=
er a
=C3=A9crit :
> I have tested the patch on 2.6.35.  Which implies I also needed to
> cherry-pick 870f67dcf7ef, which implements the vzalloc() call. (Lates=
t
> net-next has a problem with my HP CCISS driver/controller or the PCI
> layout, and will not boot)
>=20

Ah wait, you need to switch from cciss to hpsa driver, I hit same
problem some weeks ago ;) (and eventually rename your partitions
to /dev/sdaX instead of /dev/cciss/c0d0pX)


> According to the function_graph trace, the execution time of
> get_counters() has increased (approx) from 109 ms to 120 ms, which is
> the expected result.
>=20
> The results are not all positive, but I think its related to the
> debugging options I have enabled.
>=20
> Because I now see packet drops if my 1Gbit/s pktgen script are sendin=
g
> packet with a packet size below 512 bytes, which is "only" approx 230
> kpps (this is 1Gbit/s on my 10G labsetup where I have seen 5 Mpps).
>=20



> There is no packet overruns/drops, iif I run "iptables -vnL >
> /dev/null" without tracing enabled and only 1Gbit/s pktgen at 512
> bytes packets.  If I enable tracing while calling iptables I see
> packet drops/overruns.  So I guess this is caused by the tracing
> overhead.

yes, probably :)

>=20
> I'll try to rerun my test without all the lock debugging options
> enabled.
>=20

Thanks !


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
