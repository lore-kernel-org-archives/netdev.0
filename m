From: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>
Subject: [PATCH net-next 0/4] bridge: multicast snooping exports #2
Date: Mon,  7 Jul 2014 05:41:15 +0200
Message-ID: <1404704477-19448-1-git-send-email-linus.luessing@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: b.a.t.m.a.n@lists.open-mesh.org, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org,
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

Hi,

Some people pointed out to me that it might be helpful to add stubs for
the newly added multicast exports. That way e.g. batman-adv should contin=
ue
to be compile and useable without having to have a kernel compiled
with bridge code in the future. This is what the first patch is supposed
to do.

The second patch adds a third multicast export for the bridge which
e.g. batman-adv is supposed to use, too, soon: Just like the bridge
disables its multicast snooping activities if no querier is present,
batman-adv needs to do the same if bridges are involved.


These three exports should be the final ones needed to marry the bridge
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
for instance (now including the third export):

http://git.open-mesh.org/batman-adv.git/commitdiff/61e4f6af4b7a21ed4040f2=
e711d50c778e5b6d93?hp=3D6ae4281474675fbca5bedcf768972a32db586eb6

Cheers, Linus
