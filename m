From: Mauro Carvalho Chehab <mchehab@s-opensource.com>
Subject: [PATCH v2 30/53] net: fix some identation issues at kernel-doc markups
Date: Tue, 16 May 2017 09:16:22 -0300
Message-ID: <d651983dde41a854e25664d98cbfc999d55785a8.1494935649.git.mchehab@s-opensource.com>
References: <cover.1494935649.git.mchehab@s-opensource.com>
Cc: Mauro Carvalho Chehab <mchehab@s-opensource.com>,
        Mauro Carvalho Chehab <mchehab@infradead.org>,
        linux-kernel@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>,
        David Woodhouse <dwmw2@infradead.org>,
        Brian Norris <computersforpeace@gmail.com>,
        Boris Brezillon <boris.brezillon@free-electrons.com>,
        Marek Vasut <marek.vasut@gmail.com>,
        Richard Weinberger <richard@nod.at>,
        Cyrille Pitchen <cyrille.pitchen@atmel.com>,
        linux-mtd@lists.infradead.org, Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Paolo Abeni <pabeni@redhat.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
To: Linux Doc Mailing List <linux-doc@vger.kernel.org>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <cover.1494935649.git.mchehab@s-opensource.com>
In-Reply-To: <cover.1494935649.git.mchehab@s-opensource.com>
References: <cover.1494935649.git.mchehab@s-opensource.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sphinx is very pedantic with regards to identation and
escape sequences:

  ./include/net/sock.h:1967: ERROR: Unexpected indentation.
  ./include/net/sock.h:1969: ERROR: Unexpected indentation.
  ./include/net/sock.h:1970: WARNING: Block quote ends without a blank line; unexpected unindent.
  ./include/net/sock.h:1971: WARNING: Block quote ends without a blank line; unexpected unindent.
  ./include/net/sock.h:2268: WARNING: Inline emphasis start-string without end-string.
  ./net/core/sock.c:2686: ERROR: Unexpected indentation.
  ./net/core/sock.c:2687: WARNING: Block quote ends without a blank line; unexpected unindent.
  ./net/core/datagram.c:182: WARNING: Inline emphasis start-string without end-string.
  ./include/linux/netdevice.h:1444: ERROR: Unexpected indentation.
  ./drivers/net/phy/phy.c:381: ERROR: Unexpected indentation.
  ./drivers/net/phy/phy.c:382: WARNING: Block quote ends without a blank line; unexpected unindent.

- Fix spacing where needed;
- Properly escape constants;
- Use a literal block for a race description.

No functional changes.

Signed-off-by: Mauro Carvalho Chehab <mchehab@s-opensource.com>
---
 drivers/net/phy/phy.c     | 1 +
 include/linux/netdevice.h | 9 +++++----
 include/net/sock.h        | 9 ++++-----
 net/core/datagram.c       | 2 +-
 net/core/sock.c           | 7 +++++--
 5 files changed, 16 insertions(+), 12 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 82ab8fb82587..709b8be53443 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -377,6 +377,7 @@ static void phy_sanitize_settings(struct phy_device *phydev)
  * @cmd: ethtool_cmd
  *
  * A few notes about parameter checking:
+ *
  * - We don't set port or transceiver, so we don't care what they
  *   were set to.
  * - phy_start_aneg() will make sure forced settings are sane, and
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 9c23bd2efb56..56d54b6fac45 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1433,13 +1433,14 @@ enum netdev_priv_flags {
 
 /**
  *	struct net_device - The DEVICE structure.
- *		Actually, this whole structure is a big mistake.  It mixes I/O
- *		data with strictly "high-level" data, and it has to know about
- *		almost every data structure used in the INET module.
+ *
+ *	Actually, this whole structure is a big mistake.  It mixes I/O
+ *	data with strictly "high-level" data, and it has to know about
+ *	almost every data structure used in the INET module.
  *
  *	@name:	This is the first field of the "visible" part of this structure
  *		(i.e. as seen by users in the "Space.c" file).  It is the name
- *	 	of the interface.
+ *		of the interface.
  *
  *	@name_hlist: 	Device name hash chain, please keep it close to name[]
  *	@ifalias:	SNMP alias
diff --git a/include/net/sock.h b/include/net/sock.h
index 66349e49d468..9ca99b5c1328 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1953,11 +1953,10 @@ static inline bool sk_has_allocations(const struct sock *sk)
  * The purpose of the skwq_has_sleeper and sock_poll_wait is to wrap the memory
  * barrier call. They were added due to the race found within the tcp code.
  *
- * Consider following tcp code paths:
+ * Consider following tcp code paths::
  *
- * CPU1                  CPU2
- *
- * sys_select            receive packet
+ *   CPU1                CPU2
+ *   sys_select          receive packet
  *   ...                 ...
  *   __add_wait_queue    update tp->rcv_nxt
  *   ...                 ...
@@ -2264,7 +2263,7 @@ void __sock_tx_timestamp(__u16 tsflags, __u8 *tx_flags);
  * @tsflags:	timestamping flags to use
  * @tx_flags:	completed with instructions for time stamping
  *
- * Note : callers should take care of initial *tx_flags value (usually 0)
+ * Note: callers should take care of initial ``*tx_flags`` value (usually 0)
  */
 static inline void sock_tx_timestamp(const struct sock *sk, __u16 tsflags,
 				     __u8 *tx_flags)
diff --git a/net/core/datagram.c b/net/core/datagram.c
index db1866f2ffcf..4dd594741b6d 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -181,7 +181,7 @@ static struct sk_buff *skb_set_peeked(struct sk_buff *skb)
  *
  *	This function will lock the socket if a skb is returned, so
  *	the caller needs to unlock the socket in that case (usually by
- *	calling skb_free_datagram). Returns NULL with *err set to
+ *	calling skb_free_datagram). Returns NULL with @err set to
  *	-EAGAIN if no data was available or to some other value if an
  *	error was detected.
  *
diff --git a/net/core/sock.c b/net/core/sock.c
index 79c6aee6af9b..6adc69edfdd6 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2682,9 +2682,12 @@ EXPORT_SYMBOL(release_sock);
  * @sk: socket
  *
  * This version should be used for very small section, where process wont block
- * return false if fast path is taken
+ * return false if fast path is taken:
+ *
  *   sk_lock.slock locked, owned = 0, BH disabled
- * return true if slow path is taken
+ *
+ * return true if slow path is taken:
+ *
  *   sk_lock.slock unlocked, owned = 1, BH enabled
  */
 bool lock_sock_fast(struct sock *sk)
-- 
2.9.3

