From: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>
Subject: bride: IPv6 multicast snooping enhancements
Date: Wed,  4 Sep 2013 02:13:37 +0200
Message-ID: <1378253619-23918-1-git-send-email-linus.luessing@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Herbert Xu <herbert@gondor.apana.org.au>, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, Adam Baker <linux@baker-net.org.uk>,
	Stephen Hemminger <stephen@networkplumber.org>,
	=?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>,
	"David S. Miller" <davem@davemloft.net>, Cong Wang <amwang@redhat.com>
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

Here are two, small feature changes I would like to submit to increase
the usefulness of the multicast snooping of the bridge code.

The first patch is an unaltered one I had submitted before, but since it
got no feedback I'm resubmitting it here for net-next. With the recently
added patch to disable snooping if there is no querier (b00589af + 248ba8=
ec05
+ 8d50af4fb), it should be a safe choice now (without these, patch 1/2 wo=
uld
have introduced another potential for lost IPv6 multicast packets).

Both conceptually and also with some testing and fuzzing, I couldn't spot
any more causes for potential packet loss. And since the multicast snoopi=
ng
code has now been tried by various people, I think it should be a safe
choice to apply the multicast snooping not only for IPv6 multicast packet=
s
with a scope greater than link-local, but also for packets of exactly thi=
s
scope. The IPv6 standard mandates MLD reports for link-local multicast, t=
oo,
so we can safely snoop them as well (in contrast to IPv4 link-local).

Cheers, Linus
