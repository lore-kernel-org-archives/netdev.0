From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: [PATCH net-next v2 0/5] hv_netvsc: cleanup after untangling the
 pointer mess
Date: Fri,  3 Jun 2016 17:50:57 +0200
Message-ID: <1464969062-22132-1-git-send-email-vkuznets@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@linuxdriverproject.org, Haiyang Zhang <haiyangz@microsoft.com>,
 linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

Changes since v1:
- resend when net-next is open [David Miller]
- rebased to current net-next.

After we made traveling through our internal structures explicit it became
obvious that some functions take arguments they don't need just to do
redundant pointer travel and get to what they really need while their
callers already have the required information.

This is just a cleanup series with no functional changes intended. It
doesn't pretend to be complete, additional cleanup of other functions may
follow.

Vitaly Kuznetsov (5):
  hv_netvsc: remove redundant assignment in netvsc_recv_callback()
  hv_netvsc: introduce {net,hv}_device_to_netvsc_device() helpers
  hv_netvsc: pass struct netvsc_device to rndis_filter_{open,close}()
  hv_netvsc: pass struct net_device to rndis_filter_set_device_mac()
  hv_netvsc: pass struct net_device to rndis_filter_set_offload_params()

 drivers/net/hyperv/hyperv_net.h   | 19 +++++++++++++++---
 drivers/net/hyperv/netvsc.c       | 11 +++-------
 drivers/net/hyperv/netvsc_drv.c   | 18 ++++++-----------
 drivers/net/hyperv/rndis_filter.c | 42 ++++++++++++---------------------------
 4 files changed, 38 insertions(+), 52 deletions(-)

-- 
2.5.5
