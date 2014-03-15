From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: [PATCH net-next, v2,
 0/1] hyperv: Add support for virtual Receive Side Scaling (vRSS)
Date: Sat, 15 Mar 2014 10:18:06 -0700
Message-ID: <1394903887-30421-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, jasowang@redhat.com, driverdev-devel@linuxdriverproject.org,
 linux-kernel@vger.kernel.org, haiyangz@microsoft.com
To: davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

In this updated version, I have re-written the send queue selection, which is
based on ndo_select_queue now. I also applied the stop/wake queue for each
queue separately as suggested by reviewers.

Tom Herbert <therbert@google.com> has submitted a Toeplitz library function with
some optimization. But it's not accepted yet. I'm still using my Toeplitz
implementation in netvsc module. Please accept my patch if no other issues, 
because it already provides significant performance enhancement at current
state. I will be happy to switch to the Toeplitz library function when it's
accepted in the future.

Haiyang Zhang (1):
  hyperv: Add support for virtual Receive Side Scaling (vRSS)

 drivers/net/hyperv/hyperv_net.h   |  111 ++++++++++++++++++++++-
 drivers/net/hyperv/netvsc.c       |  132 +++++++++++++++++++++-----
 drivers/net/hyperv/netvsc_drv.c   |  104 ++++++++++++++++++++-
 drivers/net/hyperv/rndis_filter.c |  186 ++++++++++++++++++++++++++++++++++++-
 4 files changed, 500 insertions(+), 33 deletions(-)

-- 
1.7.4.1
