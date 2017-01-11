From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH net-next] bridge: multicast to unicast
Date: Wed, 11 Jan 2017 10:17:58 +0100
Message-ID: <1484126278.23671.3.camel@sipsolutions.net>
References: <20170109231203.GC5513@otheros>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	Michael Braun <michael-dev@fami-braun.de>,
	"David S . Miller" <davem@davemloft.net>, Felix Fietkau <nbd@nbd.name>
To: Linus =?ISO-8859-1?Q?L=FCssing?= <linus.luessing@c0d3.blue>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20170109231203.GC5513@otheros>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org


> > Exactly. My point is that this is breaking the expectation that
> > hosts are actually able to drop such packets.
> 
> [readding CCs I removed earlier]
> 
> Ah! Thanks. I was worried about creating packetloss :D.

Ah, well, no - at least not in this case.

> Hm, for this other other way round, I think it does not apply for
> the bridge multicast-to-unicast patch if I'm not misreading the
> bridge code:
> 
> For a packet with a link-layer multicast address but a unicast IP
> destination, the bridge MDB lookup will fail.
> (http://lxr.free-electrons.com/source/net/bridge/br_multicast.c?v=4.8
> #L178
>  returns NULL)
> 
> Case A): No multicast router on port:
> -> bridge, br_multicast_flood(), will drop the packet already
>    (no matter if multicast-to-unicast is enabled or not)
> 
> Case B): Multicast router present on port:
> -> The new patch does not apply multicast-to-unicast but just floods
>    packet unaltered
>    ("else { port = rport; addr = NULL; }" branch)

Ah, interesting. This is different then - the mac80211 code is not L3
aware at all.

johannes
