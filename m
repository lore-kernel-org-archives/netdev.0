From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dev_change_net_namespace: send a KOBJ_REMOVED/KOBJ_ADD
Date: Tue, 04 Dec 2012 13:26:27 -0500 (EST)
Message-ID: <20121204.132627.567823078168164756.davem@davemloft.net>
References: <20121204021712.GA10268@sergelap>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	ebiederm@xmission.com, dlezcano@free.fr
To: serge.hallyn@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121204021712.GA10268@sergelap>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Serge Hallyn <serge.hallyn@canonical.com>
Date: Mon, 3 Dec 2012 20:17:12 -0600

> When a new nic is created in namespace ns1, the kernel sends a KOBJ_ADD uevent
> to ns1.  When the nic is moved to ns2, we only send a KOBJ_MOVE to ns2, and
> nothing to ns1.
> 
> This patch changes that behavior so that when moving a nic from ns1 to ns2, we
> send a KOBJ_REMOVED to ns1 and KOBJ_ADD to ns2.  (The KOBJ_MOVE is still
> sent to ns2).
> 
> The effects of this can be seen when starting and stopping containers in
> an upstart based host.  Lxc will create a pair of veth nics, the kernel
> sends KOBJ_ADD, and upstart starts network-instance jobs for each.  When
> one nic is moved to the container, because no KOBJ_REMOVED event is
> received, the network-instance job for that veth never goes away.  This
> was reported at https://bugs.launchpad.net/ubuntu/+source/lxc/+bug/1065589
> With this patch the networ-instance jobs properly go away.
> 
> The other oddness solved here is that if a nic is passed into a running
> upstart-based container, without this patch no network-instance job is
> started in the container.  But when the container creates a new nic
> itself (ip link add new type veth) then network-interface jobs are
> created.  With this patch, behavior comes in line with a regular host.
> 
> v2: also send KOBJ_ADD to new netns.  There will then be a
> _MOVE event from the device_rename() call, but that should
> be innocuous.
> 
> Signed-off-by: Serge Hallyn <serge.hallyn@canonical.com>
> Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>
> Acked-by: Daniel Lezcano <daniel.lezcano@free.fr>

Applied, thanks.
