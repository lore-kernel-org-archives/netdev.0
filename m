From: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@c0d3.blue>
Subject: [PATCHv3 net-next 0/2] Exporting IGMP/MLD checking from bridge code
Date: Sat,  2 May 2015 14:01:05 +0200
Message-ID: <1430568067-6912-1-git-send-email-linus.luessing@c0d3.blue>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
To: b.a.t.m.a.n@lists.open-mesh.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Tom Herbert <tom@herbertland.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The multicast optimizations in batman-adv are yet only usable and
enabled in non-bridged scenarios. To be able to support bridged setups
batman-adv needs to be able to detect IGMP/MLD queriers and reports on
mesh nodes without bridges, too. See the following link for details:

http://www.open-mesh.org/projects/batman-adv/wiki/Multicast-optimizations-listener-reports

To avoid duplicate code between the bridge and batman-adv, the IGMP/MLD
message validation code is moved from the bridge to the IPv4/IPv6 stack.

On the way, some refactoring to increase readability and to iron out
some subtle differences between the IGMP and MLD parsing code is done.

Cheers, Linus


Changelog v3:
* changed interface / restructuring of skb_checksum_trimmed()
* kernel doc for skb_checksum_trimmed()/skb_checksum_maybe_trim()
* fixed a memory leak in the cloned skb case in skb_checksum_trimmed()
* fixed transport_len calculation in __ipv6_mc_check_mld(),
  make it relative to the skb transport header offset
  (= exclude the hop-by-hop option size in transport_len)

Changelog v2:
* Updated copyright for mcast_snoop.c
