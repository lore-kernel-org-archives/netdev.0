From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 2/2] bonding: debugfs and network namespaces are incompatible
Date: Mon, 09 Jul 2012 13:52:43 -0700
Message-ID: <87sjd03bdw.fsf_-_@xmission.com>
References: <1340900320.3441.88.camel@pro6455b.example.com>
	<20120705220749.GA11255@mail.hallyn.com> <87ehopu3e5.fsf@xmission.com>
	<20120706170538.GA31679@mail.hallyn.com> <87fw94g1kq.fsf@xmission.com>
	<20120706194741.GA22113@mail.hallyn.com>
	<87y5ms3bfi.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	Dilip Daya <dilip.daya-VXdhtT5mjnY@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87y5ms3bfi.fsf_-_-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> (Eric W. Biederman's message of
	"Mon, 09 Jul 2012 13:51:45 -0700")
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


The bonding debugfs support has been broken in the presence of network
namespaces since it has been added.  The debugfs support does not handle
multiple bonding devices with the same name in different network
namespaces.

I haven't had any bug reports, and I'm not interested in getting any.
Disable the debugfs support when network namespaces are enabled.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 drivers/net/bonding/bond_debugfs.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bonding/bond_debugfs.c b/drivers/net/bonding/bond_debugfs.c
index 3680aa2..2cf084e 100644
--- a/drivers/net/bonding/bond_debugfs.c
+++ b/drivers/net/bonding/bond_debugfs.c
@@ -6,7 +6,7 @@
 #include "bonding.h"
 #include "bond_alb.h"
 
-#ifdef CONFIG_DEBUG_FS
+#if defined(CONFIG_DEBUG_FS) && !defined(CONFIG_NET_NS)
 
 #include <linux/debugfs.h>
 #include <linux/seq_file.h>
-- 
1.7.5.4
