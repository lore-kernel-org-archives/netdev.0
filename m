From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: vxlan: convert to act as a pernet
 subsystem
Date: Wed, 22 Jan 2014 17:44:03 -0800 (PST)
Message-ID: <20140122.174403.589765636868016392.davem@davemloft.net>
References: <1390421273-20152-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse.brandeburg@intel.com,
	ebiederm@xmission.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52511 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752331AbaAWBoD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 20:44:03 -0500
In-Reply-To: <1390421273-20152-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Wed, 22 Jan 2014 21:07:53 +0100

> As per suggestion from Eric W. Biederman, vxlan should be using
> {un,}register_pernet_subsys() instead of {un,}register_pernet_device()
> to ensure the vxlan_net structure is initialized before and cleaned
> up after all network devices in a given network namespace i.e. when
> dealing with network notifiers. This is similarly handeled already in
> commit 91e2ff3528ac ("net: Teach vlans to cleanup as a pernet subsystem")
> and, thus, improves upon fd27e0d44a89 ("net: vxlan: do not use vxlan_net
> before checking event type"). Just as in 91e2ff3528ac, we do not need
> to explicitly handle deletion of vxlan devices as network namespace
> exit calls dellink on all remaining virtual devices, and
> rtnl_link_unregister() calls dellink on all outstanding devices in that
> network namespace, so we can entirely drop the pernet exit operation
> as well. Moreover, on vxlan module exit, rcu_barrier() is called by
> netns since commit 3a765edadb28 ("netns: Add an explicit rcu_barrier
> to unregister_pernet_{device|subsys}"), so this may be omitted. Tested
> with various scenarios and works well on my side.
> 
> Suggested-by: Eric W. Biederman <ebiederm@xmission.com>
> Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Cc: Eric W. Biederman <ebiederm@xmission.com>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied, thanks.
