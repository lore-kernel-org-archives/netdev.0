From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH 5/5] net core: fix kernel-doc for new function parameters
Date: Fri, 12 Oct 2007 21:17:49 -0700
Message-ID: <20071012211749.9e3f9971.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: torvalds <torvalds@linux-foundation.org>,
	akpm <akpm@linux-foundation.org>, davem@davemloft.net
To: lkml <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:30066 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751171AbXJMESv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Oct 2007 00:18:51 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix networking code kernel-doc for newly added parameters.

Warning(linux-2.6.23-git2//net/core/sock.c:879): No description found for parameter 'net'
Warning(linux-2.6.23-git2//net/core/dev.c:570): No description found for parameter 'net'
Warning(linux-2.6.23-git2//net/core/dev.c:594): No description found for parameter 'net'
Warning(linux-2.6.23-git2//net/core/dev.c:617): No description found for parameter 'net'
Warning(linux-2.6.23-git2//net/core/dev.c:641): No description found for parameter 'net'
Warning(linux-2.6.23-git2//net/core/dev.c:667): No description found for parameter 'net'
Warning(linux-2.6.23-git2//net/core/dev.c:722): No description found for parameter 'net'
Warning(linux-2.6.23-git2//net/core/dev.c:959): No description found for parameter 'net'
Warning(linux-2.6.23-git2//net/core/dev.c:1195): No description found for parameter 'dev'
Warning(linux-2.6.23-git2//net/core/dev.c:2105): No description found for parameter 'n'
Warning(linux-2.6.23-git2//net/core/dev.c:3272): No description found for parameter 'net'
Warning(linux-2.6.23-git2//net/core/dev.c:3445): No description found for parameter 'net'
Warning(linux-2.6.23-git2//include/linux/netdevice.h:1301): No description found for parameter 'cpu'

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 include/linux/netdevice.h |    1 +
 net/core/dev.c            |   13 +++++++++++--
 net/core/sock.c           |    1 +
 3 files changed, 13 insertions(+), 2 deletions(-)

--- linux-2.6.23-git2.orig/include/linux/netdevice.h
+++ linux-2.6.23-git2/include/linux/netdevice.h
@@ -1294,6 +1294,7 @@ static inline void netif_rx_complete(str
 /**
  *	netif_tx_lock - grab network device transmit lock
  *	@dev: network device
+ *	@cpu: cpu number of lock owner
  *
  * Get network device transmit lock
  */
--- linux-2.6.23-git2.orig/net/core/sock.c
+++ linux-2.6.23-git2/net/core/sock.c
@@ -869,6 +869,7 @@ static inline void sock_lock_init(struct
 
 /**
  *	sk_alloc - All socket objects are allocated here
+ *	@net: the applicable net namespace
  *	@family: protocol family
  *	@priority: for allocation (%GFP_KERNEL, %GFP_ATOMIC, etc)
  *	@prot: struct proto associated with this new sock instance
--- linux-2.6.23-git2.orig/net/core/dev.c
+++ linux-2.6.23-git2/net/core/dev.c
@@ -557,6 +557,7 @@ __setup("netdev=", netdev_boot_setup);
 
 /**
  *	__dev_get_by_name	- find a device by its name
+ *	@net: the applicable net namespace
  *	@name: name to find
  *
  *	Find an interface by name. Must be called under RTNL semaphore
@@ -581,6 +582,7 @@ struct net_device *__dev_get_by_name(str
 
 /**
  *	dev_get_by_name		- find a device by its name
+ *	@net: the applicable net namespace
  *	@name: name to find
  *
  *	Find an interface by name. This can be called from any
@@ -604,6 +606,7 @@ struct net_device *dev_get_by_name(struc
 
 /**
  *	__dev_get_by_index - find a device by its ifindex
+ *	@net: the applicable net namespace
  *	@ifindex: index of device
  *
  *	Search for an interface by index. Returns %NULL if the device
@@ -629,6 +632,7 @@ struct net_device *__dev_get_by_index(st
 
 /**
  *	dev_get_by_index - find a device by its ifindex
+ *	@net: the applicable net namespace
  *	@ifindex: index of device
  *
  *	Search for an interface by index. Returns NULL if the device
@@ -651,6 +655,7 @@ struct net_device *dev_get_by_index(stru
 
 /**
  *	dev_getbyhwaddr - find a device by its hardware address
+ *	@net: the applicable net namespace
  *	@type: media type of device
  *	@ha: hardware address
  *
@@ -709,6 +714,7 @@ EXPORT_SYMBOL(dev_getfirstbyhwtype);
 
 /**
  *	dev_get_by_flags - find any device with given flags
+ *	@net: the applicable net namespace
  *	@if_flags: IFF_* values
  *	@mask: bitmask of bits in if_flags to check
  *
@@ -948,6 +954,7 @@ void netdev_state_change(struct net_devi
 
 /**
  *	dev_load 	- load a network module
+ *	@net: the applicable net namespace
  *	@name: name of interface
  *
  *	If a network interface is not present and the process has suitable
@@ -1185,7 +1192,7 @@ int unregister_netdevice_notifier(struct
 /**
  *	call_netdevice_notifiers - call all network notifier blocks
  *      @val: value passed unmodified to notifier function
- *      @v:   pointer passed unmodified to notifier function
+ *      @dev: net_device pointer passed unmodified to notifier function
  *
  *	Call all network notifier blocks.  Parameters and return value
  *	are as for raw_notifier_call_chain().
@@ -2097,7 +2104,7 @@ static int process_backlog(struct napi_s
 
 /**
  * __napi_schedule - schedule for receive
- * @napi: entry to schedule
+ * @n: entry to schedule
  *
  * The entry's receive function will be scheduled to run
  */
@@ -3259,6 +3266,7 @@ static int dev_ifsioc(struct net *net, s
 
 /**
  *	dev_ioctl	-	network device ioctl
+ *	@net: the applicable net namespace
  *	@cmd: command to issue
  *	@arg: pointer to a struct ifreq in user space
  *
@@ -3436,6 +3444,7 @@ int dev_ioctl(struct net *net, unsigned 
 
 /**
  *	dev_new_index	-	allocate an ifindex
+ *	@net: the applicable net namespace
  *
  *	Returns a suitable unique value for a new device interface
  *	number.  The caller must hold the rtnl semaphore or the
