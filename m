From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [2.6.31 04/21] wimax/i2400m: i2400m_schedule_work() doesn't need
	i2400m->work_queue
Date: Thu, 11 Jun 2009 14:35:41 -0700
Message-ID: <16eafba8defcd507831eec926b61db474af0aabb.1244755662.git.inaky@linux.intel.com>
References: <cover.1244755662.git.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org,
	wimax@linuxwimax.org
Return-path: <wimax-bounces@linuxwimax.org>
In-Reply-To: <cover.1244755662.git.inaky@linux.intel.com>
In-Reply-To: <cover.1244755662.git.inaky@linux.intel.com>
References: <cover.1244755662.git.inaky@linux.intel.com>
List-Unsubscribe: <http://lists.linuxwimax.org/options/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=unsubscribe>
List-Archive: <http://lists.linuxwimax.org/pipermail/wimax>
List-Post: <mailto:wimax@linuxwimax.org>
List-Help: <mailto:wimax-request@linuxwimax.org?subject=help>
List-Subscribe: <http://lists.linuxwimax.org/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=subscribe>
Sender: wimax-bounces@linuxwimax.org
Errors-To: wimax-bounces@linuxwimax.org
List-Id: netdev.vger.kernel.org

By mistake, the BUG_ON() check was left in there and it will fail when
called if i2400m->work_queue is still not setup.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/driver.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wimax/i2400m/driver.c b/drivers/net/wimax/i2400m/driver.c
index 006eb12..897794c 100644
--- a/drivers/net/wimax/i2400m/driver.c
+++ b/drivers/net/wimax/i2400m/driver.c
@@ -180,7 +180,6 @@ int i2400m_schedule_work(struct i2400m *i2400m,
 	int result;
 	struct i2400m_work *iw;
 
-	BUG_ON(i2400m->work_queue == NULL);
 	result = -ENOMEM;
 	iw = kzalloc(sizeof(*iw), gfp_flags);
 	if (iw == NULL)
-- 
1.6.2.3
