From: Wei Liu <wei.liu2@citrix.com>
Subject: [RFC PATCH] New Xen netback implementation
Date: Fri, 13 Jan 2012 16:59:03 +0000
Message-ID: <1326473949-22389-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: ian.campbell@citrix.com, konrad.wilk@oracle.com,
	xen-devel@lists.xensource.com, netdev@vger.kernel.org
Return-path: <xen-devel-bounces@lists.xensource.com>
List-Unsubscribe: <http://lists.xensource.com/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

A new netback implementation which includes three major features:

 - Global page pool support
 - NAPI + kthread 1:1 model
 - Netback internal name changes

This patch series is the foundation of furture work. So it is better
to get it right first. Patch 1 and 3 have the real meat.

The first benifit of 1:1 model will be scheduling fairness.

The rational behind a global page pool is that we need to limit
overall RAM consumed by all vifs.

Utilization of NAPI enables the possibility to mitigate
interrupts/events, but this is not yet done.

Netback internal changes cleans up the code structure after switching
to 1:1 model. It also prepares netback for further code layout
changes.


---
 drivers/net/xen-netback/Makefile    |    2 +-
 drivers/net/xen-netback/common.h    |   94 +++--
 drivers/net/xen-netback/interface.c |  115 ++++--
 drivers/net/xen-netback/netback.c   |  743 +++++++++++------------------------
 drivers/net/xen-netback/page_pool.c |  183 +++++++++
 drivers/net/xen-netback/page_pool.h |   61 +++
 drivers/net/xen-netback/xenbus.c    |    6 +-
 7 files changed, 620 insertions(+), 584 deletions(-)
