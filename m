From: Konstantin Khlebnikov <khlebnikov-XoJtRXgx1JseBXzfvpsJ4g@public.gmane.org>
Subject: [PATCH] ipv4: in new netns initialize sysctls in net.ipv4.conf.*
	with defaults
Date: Sun, 21 Feb 2016 10:11:02 +0300
Message-ID: <20160221071102.9686.63148.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Vasily Averin <vvs-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Currently initial net.ipv4.conf.all.* and net.ipv4.conf.default.* are
copied from init network namespace because static structures are used
for init_net. This makes no sense because new netns might be created
from any netns. This patch makes private copy also for init netns if
network namespaces are enabled. Other sysctls in net.ipv4 and net.ipv6
already initialized with default values at namespace creation.

Signed-off-by: Konstantin Khlebnikov <khlebnikov-XoJtRXgx1JseBXzfvpsJ4g@public.gmane.org>
Fixes: 752d14dc6aa9 ("[IPV4]: Move the devinet pointers on the struct net")
---
 net/ipv4/devinet.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index cebd9d31e65a..9d73d4bbdba3 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -2290,7 +2290,7 @@ static __net_init int devinet_init_net(struct net *net)
 	all = &ipv4_devconf;
 	dflt = &ipv4_devconf_dflt;
 
-	if (!net_eq(net, &init_net)) {
+	if (IS_ENABLED(CONFIG_NET_NS)) {
 		all = kmemdup(all, sizeof(ipv4_devconf), GFP_KERNEL);
 		if (!all)
 			goto err_alloc_all;
