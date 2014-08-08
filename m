From: Paul Moore <paul@paul-moore.com>
Subject: [GIT PULL] SELinux/NetLabel fixes for 3.17
Date: Thu, 07 Aug 2014 21:15:09 -0400
Message-ID: <3757283.5i2HgyZGYY@sifl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello All,

Two small patches to fix a couple of build warnings in SELinux and NetLabel.  
The patches are obvious enough that I don't think any additional explanation 
is necessary, but it basically boils down to the usual: I was stupid, and 
these patches fix some of the stupid.

Both patches were posted earlier this week to the SELinux list, and that is 
where they sat as I didn't think there were noteworthy enough to go upstream 
at this point in time, but DaveM would rather see them upstream now so who am 
I to argue.  As the patches are both very small, I'm including the combines 
changes with this pull request in case anyone wants to scrutinize them any 
further.

Enjoy,
-Paul

--
The following changes since commit 4fbe63d1c773cceef3fe1f6ed0c9c268f4f24760:

  netlabel: shorter names for the NetLabel catmap funcs/structs
            (2014-08-01 11:17:37 -0400)

are available in the git repository at:

  git://git.infradead.org/users/pcmoore/selinux stable-3.17

for you to fetch changes up to 942ba3646543aeb3e5729c35d10ac43424bf0b68:

  selinux: remove unused variabled in the netport, netnode, and netif
           caches (2014-08-07 20:55:30 -0400)

----------------------------------------------------------------
Paul Moore (2):
      netlabel: fix the netlbl_catmap_setlong() dummy function
      selinux: remove unused variabled in the netport, netnode, and netif
               caches

 include/net/netlabel.h     | 8 ++++----
 security/selinux/netif.c   | 4 ++--
 security/selinux/netnode.c | 3 +--
 security/selinux/netport.c | 3 +--
 4 files changed, 8 insertions(+), 10 deletions(-)

diff --git a/include/net/netlabel.h b/include/net/netlabel.h
index a4fc39b..7b5a300 100644
--- a/include/net/netlabel.h
+++ b/include/net/netlabel.h
@@ -524,10 +524,10 @@ static inline int netlbl_catmap_setrng(struct 
netlbl_lsm_catmap **catmap,
 {
 	return 0;
 }
-static int netlbl_catmap_setlong(struct netlbl_lsm_catmap **catmap,
-				 u32 offset,
-				 unsigned long bitmap,
-				 gfp_t flags)
+static inline int netlbl_catmap_setlong(struct netlbl_lsm_catmap **catmap,
+					u32 offset,
+					unsigned long bitmap,
+					gfp_t flags)
 {
 	return 0;
 }
diff --git a/security/selinux/netif.c b/security/selinux/netif.c
index 3c3de4c..50ce177 100644
--- a/security/selinux/netif.c
+++ b/security/selinux/netif.c
@@ -272,7 +272,7 @@ static struct notifier_block sel_netif_netdev_notifier = {
 
 static __init int sel_netif_init(void)
 {
-	int i, err;
+	int i;
 
 	if (!selinux_enabled)
 		return 0;
@@ -282,7 +282,7 @@ static __init int sel_netif_init(void)
 
 	register_netdevice_notifier(&sel_netif_netdev_notifier);
 
-	return err;
+	return 0;
 }
 
 __initcall(sel_netif_init);
diff --git a/security/selinux/netnode.c b/security/selinux/netnode.c
index ddf3152..da923f8 100644
--- a/security/selinux/netnode.c
+++ b/security/selinux/netnode.c
@@ -303,7 +303,6 @@ void sel_netnode_flush(void)
 static __init int sel_netnode_init(void)
 {
 	int iter;
-	int ret;
 
 	if (!selinux_enabled)
 		return 0;
@@ -313,7 +312,7 @@ static __init int sel_netnode_init(void)
 		sel_netnode_hash[iter].size = 0;
 	}
 
-	return ret;
+	return 0;
 }
 
 __initcall(sel_netnode_init);
diff --git a/security/selinux/netport.c b/security/selinux/netport.c
index 73ac678..3311cc3 100644
--- a/security/selinux/netport.c
+++ b/security/selinux/netport.c
@@ -237,7 +237,6 @@ void sel_netport_flush(void)
 static __init int sel_netport_init(void)
 {
 	int iter;
-	int ret;
 
 	if (!selinux_enabled)
 		return 0;
@@ -247,7 +246,7 @@ static __init int sel_netport_init(void)
 		sel_netport_hash[iter].size = 0;
 	}
 
-	return ret;
+	return 0;
 }
 
 __initcall(sel_netport_init);

-- 
paul moore
security and virtualization @ redhat
