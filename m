From: Daniel Wagner <wagi@monom.org>
Subject: [PATCH v0 0/5] cgroup: Assign subsystem IDs during compile time
Date: Thu, 16 Aug 2012 16:12:11 +0200
Message-ID: <1345126336-20755-1-git-send-email-wagi@monom.org>
Cc: Daniel Wagner <daniel.wagner@bmw-carit.de>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Eric Dumazet <edumazet@google.com>,
	Gao feng <gaofeng@cn.fujitsu.com>,
	Glauber Costa <glommer@parallels.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>,
	Li Zefan <lizefan@huawei.com>,
	Neil Horman <nhorman@tuxdriver.com>, Tejun Heo <tj@kernel.org>
To: netdev@vger.kernel.org, cgroups@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hotel311.server4you.de ([85.25.146.15]:32903 "EHLO
	hotel311.server4you.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751388Ab2HPOMT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2012 10:12:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Wagner <daniel.wagner@bmw-carit.de>

Hi,

The patch #1 and #2 are there to be able to introduce (#3, #4) the 
jump labels in task_cls_classid() and task_netprioidx(). The jump
labels are needed to know when it is safe to access the controller. 
For example not safe means the module is not yet loaded.

All those patches are just preparation for the center piece (#5) 
of these series. This one will remove the dynamic subsystem ID
generation and falls back to compile time generated IDs. 

This is the first result from the discussion around on the
"cgroup cls & netprio 'cleanups'" patches.

This patches are against net-next

cheers,
daniel

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Gao feng <gaofeng@cn.fujitsu.com>
Cc: Glauber Costa <glommer@parallels.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: John Fastabend <john.r.fastabend@intel.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Li Zefan <lizefan@huawei.com>
Cc: Neil Horman <nhorman@tuxdriver.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: netdev@vger.kernel.org
Cc: cgroups@vger.kernel.org

Daniel Wagner (5):
  cgroup: Use empty task_cls_classid() when !CONFIG_NET_CLS(_MODULE)
  cgroup: Move sock_update_classid() decleration to cls_cgroup.h
  cgroup: Protect access to task_cls_classid() when built as module
  cgroup: Protect access to task_netprioidx() when built as module
  cgroup: Assign subsystem IDs during compile time

 include/linux/cgroup.h        | 20 +++++++++++++-------
 include/linux/cgroup_subsys.h | 24 ++++++++++++------------
 include/net/cls_cgroup.h      | 42 +++++++++++++++++++++++++++++-------------
 include/net/netprio_cgroup.h  | 23 +++++++++++------------
 include/net/sock.h            |  8 --------
 kernel/cgroup.c               | 31 +++++++++----------------------
 net/core/netprio_cgroup.c     | 17 ++++++-----------
 net/core/sock.c               | 12 ++++++------
 net/sched/cls_cgroup.c        | 18 +++++-------------
 9 files changed, 91 insertions(+), 104 deletions(-)

-- 
1.7.12.rc1.16.g05a20c8
