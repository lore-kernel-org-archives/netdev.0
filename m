From: Daniel Wagner <wagi@monom.org>
Subject: [PATCH v0 0/4] Rework net_cls update socket logic
Date: Wed, 17 Oct 2012 15:04:34 +0200
Message-ID: <1350479078-29361-1-git-send-email-wagi@monom.org>
Cc: Daniel Wagner <daniel.wagner@bmw-carit.de>,
	Li Zefan <lizefan@huawei.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	Glauber Costa <glommer@parallels.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Joe Perches <joe@perches.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Stanislav Kinsbursky <skinsbursky@parallels.com>,
	Tejun Heo <tj@kernel.org>
To: netdev@vger.kernel.org, cgroups@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hotel311.server4you.de ([85.25.146.15]:43165 "EHLO
	hotel311.server4you.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755859Ab2JQNEm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2012 09:04:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Wagner <daniel.wagner@bmw-carit.de>

Hi,

This series updates net_cls to use the same socket update logic as
net_prio. With this change sock_update_classid() is not called from
recvmsg, sendmsg and friends anymore. This seems to be a good idea.

Credit goes to John Fastabend for this work.

The patches are against net-next.

cheers,
daniel

Cc:  Li Zefan <lizefan@huawei.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Glauber Costa <glommer@parallels.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: Joe Perches <joe@perches.com>
Cc: John Fastabend <john.r.fastabend@intel.com>
Cc: Li Zefan <lizefan@huawei.com>
Cc: Neil Horman <nhorman@tuxdriver.com>
Cc: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: <cgroups@vger.kernel.org>
Cc: <netdev@vger.kernel.org>

Daniel Wagner (4):
  cgroup: net_prio: Mark local used function static
  cgroup: net_cls: Fix local variable type decleration
  cgroup: net_cls: Pass in task to sock_update_classid()
  cgroup: net_cls: Rework update socket logic

 drivers/net/tun.c         |  3 ---
 include/net/cls_cgroup.h  |  4 ++--
 net/core/netprio_cgroup.c |  2 +-
 net/core/sock.c           |  6 +++---
 net/sched/cls_cgroup.c    | 38 ++++++++++++++++++++++++++++++++++++++
 net/socket.c              |  8 --------
 6 files changed, 44 insertions(+), 17 deletions(-)

-- 
1.7.11.4
