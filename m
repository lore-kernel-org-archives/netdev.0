From: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>
Subject: [PATCHv4 net-next 0/4] bridge: multicast snooping patches
	/ exports
Date: Sat,  7 Jun 2014 18:26:25 +0200
Message-ID: <1402158389-13239-1-git-send-email-linus.luessing@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: b.a.t.m.a.n@lists.open-mesh.org, Herbert Xu <herbert@gondor.apana.org.au>,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	=?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
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

The first patch is simply a cosmetic patch. So far I (and maybe others
too?) have been regularly confusing these two structs, therefore I'd
suggest renaming them and therefore making the follow-up patches easier
to understand and nicer to fit in.

The second patch fixes a minor issue, but probably not worth for stable.


On the other hand the first two patches are also preparations for the
third and fourth patch:

These two patches are exporting functionality needed to marry the bridge
multicast snooping with the batman-adv multicast optimizations recently
added for the 3.15 kernel, allowing to use these optimzations in common
setups having a bridge on top of e.g. bat0, too. So far these bridged
setups would fall back to simple flooding through the batman-adv mesh
network for any multicast packet entering bat0.

More information about the batman-adv multicast optimizations currently
implemented can be found here:

http://www.open-mesh.org/projects/batman-adv/wiki/Basic-multicast-optimiz=
ations

The integration on the batman-adv side could afterwards look like this,
for instance:

http://git.open-mesh.org/batman-adv.git/commitdiff/576b59dd3e34737c702e54=
8b21fa72059262f796?hp=3Df95ce7131746c65fbcdffcf2089cab59e2c2f7ac


Changes in v4:
 - merged header postings from all previous patchset versions

Changes in v3:
 - use EXPORT_SYMBOL_GPL() instead of EXPORT_SYMBOL()

Changes in v2:
 - fix a nasty typo in PATCH 1/4, br_multicast_update_query_timer():
   "br->multicast_query_interval" vs. "br->multicast_querier_interval"
   =3D> this accidentally reduced the other querier present timer=20
      from 255 to 125 seconds
 - fix a typo in PATCH 2/4, br_ip{4,6}_multicast_query():
   ntohs(ETH_P_{IP,IPV6}) vs. htons(ETH_P_{IP,IPV6})
 - add missing ntohl()s before address comparison in PATCH 2/4,
   br_ip4_multicast_select_querier() (thanks David!)

Cheers, Linus
