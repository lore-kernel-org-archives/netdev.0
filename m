From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: Make vhost multi-threaded and associate each thread to its
 guest's cgroup
Date: Tue, 27 Jul 2010 17:41:41 -0700
Message-ID: <1280277701.27059.11.camel@w-sridhar.beaverton.ibm.com>
References: <20100727204254.GA17947@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	Tejun Heo <tj@kernel.org>, Li Zefan <lizf@cn.fujitsu.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100727204254.GA17947@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2010-07-27 at 23:42 +0300, Michael S. Tsirkin wrote:
> Sridhar,
> I pushed a patchset with all known issues fixed,
> on my vhost-net-next branch.
> 
> For now this ignores the cpu mask issue, addressing
> only the cgroups issue.
> 
> Would appreciate testing and reports.

I had to apply the following patch to get it build.
With this patch, i am seeing similar results as i saw earlier.

Thanks
Sridhar

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 996e751..8543898 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -23,6 +23,7 @@
 #include <linux/highmem.h>
 #include <linux/slab.h>
 #include <linux/kthread.h>
+#include <linux/cgroup.h>
 
 #include <linux/net.h>
 #include <linux/if_packet.h>
@@ -252,7 +253,7 @@ static long vhost_dev_set_owner(struct vhost_dev *dev)
 	}
 
 	dev->worker = worker;
-	err = cgroup_attach_task_current_cg(poller);
+	err = cgroup_attach_task_current_cg(worker);
 	if (err)
 		goto err_cgroup;
 	wake_up_process(worker);	/* avoid contributing to loadavg */
