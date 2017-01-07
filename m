From: Linus =?utf-8?Q?L=C3=BCssing?= <linus.luessing@c0d3.blue>
Subject: Re: [PATCH net-next] bridge: multicast to unicast
Date: Sat, 7 Jan 2017 15:55:16 +0100
Message-ID: <20170107145516.GE3134@otheros>
References: <20170102193214.31723-1-linus.luessing@c0d3.blue>
	<1483706872.4089.8.camel@sipsolutions.net>
	<8836daaa-9638-4502-d079-fd428595f822@nbd.name>
	<1483710841.12677.1.camel@sipsolutions.net>
	<22fad045-57c6-7789-d19f-f47bd0faf441@fami-braun.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S . Miller" <davem@davemloft.net>, Felix Fietkau <nbd@nbd.name>
To: "M. Braun" <michael-dev@fami-braun.de>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <22fad045-57c6-7789-d19f-f47bd0faf441@fami-braun.de>
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

On Sat, Jan 07, 2017 at 11:32:57AM +0100, M. Braun wrote:
> Am 06.01.2017 um 14:54 schrieb Johannes Berg:
> > 
> >> The bridge layer can use IGMP snooping to ensure that the multicast
> >> stream is only transmitted to clients that are actually a member of
> >> the group. Can the mac80211 feature do the same?
> > 
> > No, it'll convert the packet for all clients that are behind that
> > netdev. But that's an argument for dropping the mac80211 feature, which
> > hasn't been merged upstream yet, no?
> 
> But there is multicast/broadcast traffic like e.g. ARP and some IP
> multicast groups that are not covered by IGMP snooping. The mac80211
> patch converts this to unicast as well, which the bridge cannot do.
> 
> That way, these features both complement and overlap each other.

Right, I'd agree with that.

I didn't write it explicitly in the commit message, but yes, the
like anything concerning bridge multicast snooping, bridge
multicast-to-unicast can only affect packets as noted in
RFC4541 ("Considerations for Internet Group Management Protocol (IGMP)
and Multicast Listener Discovery (MLD) Snooping Switches"), too.

So it is only working for IPv4 multicast, excluding link-local
(224.0.0.0/24), and IPv6 multicast, excluding all-host-multicast
(ff02::1).

And does not concern ARP in any way.


The nice complementary effect is, that the bridge can first sieve
out those IP packets thanks to IGMP/MLD snooping knowledge and for
anything else, like ARP, 224.0.0.x or ff02::1, the mac80211
multicast-to-unicast could do its job.


For APs with a small number of STAs (like your private home AP),
you might want to enable both bridge multicast-to-unicast and
mac80211 multicast-to-unicast for this complementary effect. While
on public APs with 30 to 50 STAs with varying distances and bitrates,
you might only one to enable the bridge one, because sending an ARP
packet 50x might actually reduce performance and airtime
significantly.
