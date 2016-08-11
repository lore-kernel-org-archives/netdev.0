From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: [PATCH net 0/4] hv_netvsc: fixes for VF removal path
Date: Thu, 11 Aug 2016 12:58:53 +0200
Message-ID: <1470913137-29167-1-git-send-email-vkuznets@redhat.com>
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

Kernel crash is reported after VF is removed and detached from netvsc
device. My investigation led me to PATCH2 of this series but PATCH1 is
required to support the change. I also noticed a couple of other issues
while debugging and I fix them with PATCH3 and PATCH4.

Please review.

Vitaly Kuznetsov (4):
  hv_netvsc: don't lose VF information
  hv_netvsc: reset vf_inject on VF removal
  hv_netvsc: protect module refcount by checking
    net_device_ctx->vf_netdev
  hv_netvsc: avoid deadlocks between rtnl lock and
    netvsc_inject_disable()

 drivers/net/hyperv/hyperv_net.h | 24 ++++-------
 drivers/net/hyperv/netvsc.c     | 19 ++++----
 drivers/net/hyperv/netvsc_drv.c | 96 ++++++++++++++++++-----------------------
 3 files changed, 59 insertions(+), 80 deletions(-)

-- 
2.7.4
