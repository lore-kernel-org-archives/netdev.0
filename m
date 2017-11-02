From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: [PATCH net-next v2 0/2] hv_netvsc: fix a hang on channel/mtu changes
Date: Thu,  2 Nov 2017 11:35:29 +0100
Message-ID: <20171102103531.5514-1-vkuznets@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <sthemmin@microsoft.com>,
 Eric Dumazet <eric.dumazet@gmail.com>, Haiyang Zhang <haiyangz@microsoft.com>,
 linux-kernel@vger.kernel.org, devel@linuxdriverproject.org
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

It was found that netvsc driver doesn't survive e.g.

# while true; do ethtool -L eth0 combined 4; ethtool -L eth0 combined 8; done"

test. I was able to identify a hang in guest/host communication, it is
fixed by PATCH1 of this series. PATCH2 is a cosmetic change masking
unneeded messages.

Changes since v1:
- Throw away patches 2 and 3 of the original series as one is unneeded and
  the other is not justified [Eric Dumazet, Stephen Hemminger] so I'm only
  fixing the hang now, the crash doesn't reproduce. Will keep an eye on it.

Vitaly Kuznetsov (2):
  hv_netvsc: netvsc_teardown_gpadl() split
  hv_netvsc: hide warnings about uninitialized/missing rndis device

 drivers/net/hyperv/netvsc.c       | 69 ++++++++++++++++++++-------------------
 drivers/net/hyperv/rndis_filter.c |  4 +--
 2 files changed, 38 insertions(+), 35 deletions(-)

-- 
2.13.6
