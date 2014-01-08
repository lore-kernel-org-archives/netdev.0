From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [ovs-dev] [GIT net-next] Open vSwitch
Date: Wed, 8 Jan 2014 14:49:35 +0000
Message-ID: <52CD657F.7080806@citrix.com>
References: <1389053776-62865-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <dev@openvswitch.org>, <netdev@vger.kernel.org>
To: Jesse Gross <jesse@nicira.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:10606 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751069AbaAHOti (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jan 2014 09:49:38 -0500
In-Reply-To: <1389053776-62865-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I've tried the latest net-next on a Xenserver install with 1.9.3 
userspace, and it seems this patch series broke it (at least after 
reverting that locally it works now). I haven't went too far yet 
checking what's the problem, but it seems the xenbrX device doesn't 
really receive too much of the traffic coming through the NIC. Is it 
expected?

Regards,

Zoli

On 07/01/14 00:15, Jesse Gross wrote:
> Open vSwitch changes for net-next/3.14. Highlights are:
>   * Performance improvements in the mechanism to get packets to userspace
>     using memory mapped netlink and skb zero copy where appropriate.
>   * Per-cpu flow stats in situations where flows are likely to be shared
>     across CPUs. Standard flow stats are used in other situations to save
>     memory and allocation time.
>   * A handful of code cleanups and rationalization.
>
> The following changes since commit 6ce4eac1f600b34f2f7f58f9cd8f0503d79e42ae:
>
>    Linux 3.13-rc1 (2013-11-22 11:30:55 -0800)
>
> are available in the git repository at:
>
>    git://git.kernel.org/pub/scm/linux/kernel/git/jesse/openvswitch.git master
>
> for you to fetch changes up to 443cd88c8a31379e95326428bbbd40af25c1d440:
>
>    ovs: make functions local (2014-01-06 15:54:39 -0800)
>
> ----------------------------------------------------------------
> Andy Zhou (1):
>        openvswitch: Change ovs_flow_tbl_lookup_xx() APIs
>
> Ben Pfaff (2):
>        openvswitch: Correct comment.
>        openvswitch: Shrink sw_flow_mask by 8 bytes (64-bit) or 4 bytes (32-bit).
>
> Daniel Borkmann (1):
>        net: ovs: use kfree_rcu instead of rcu_free_{sw_flow_mask_cb,acts_callback}
>
> Jesse Gross (1):
>        openvswitch: Silence RCU lockdep checks from flow lookup.
>
> Pravin B Shelar (1):
>        openvswitch: Per cpu flow stats.
>
> Stephen Hemminger (1):
>        ovs: make functions local
>
> Thomas Graf (9):
>        genl: Add genlmsg_new_unicast() for unicast message allocation
>        netlink: Avoid netlink mmap alloc if msg size exceeds frame size
>        openvswitch: Enable memory mapped Netlink i/o
>        net: Export skb_zerocopy() to zerocopy from one skb to another
>        openvswitch: Allow user space to announce ability to accept unaligned Netlink messages
>        openvswitch: Drop user features if old user space attempted to create datapath
>        openvswitch: Pass datapath into userspace queue functions
>        openvswitch: Use skb_zerocopy() for upcall
>        openvswitch: Compute checksum in skb_gso_segment() if needed
>
> Wei Yongjun (1):
>        openvswitch: remove duplicated include from flow_table.c
>
>   include/linux/skbuff.h               |   3 +
>   include/net/genetlink.h              |   4 +
>   include/uapi/linux/openvswitch.h     |  14 ++-
>   net/core/skbuff.c                    |  85 +++++++++++++
>   net/netfilter/nfnetlink_queue_core.c |  59 +--------
>   net/netlink/af_netlink.c             |   4 +
>   net/netlink/genetlink.c              |  21 ++++
>   net/openvswitch/datapath.c           | 231 +++++++++++++++++++----------------
>   net/openvswitch/datapath.h           |   6 +-
>   net/openvswitch/flow.c               |  96 +++++++++++++--
>   net/openvswitch/flow.h               |  33 +++--
>   net/openvswitch/flow_netlink.c       |  66 ++++++++--
>   net/openvswitch/flow_netlink.h       |   1 +
>   net/openvswitch/flow_table.c         |  60 ++++++---
>   net/openvswitch/flow_table.h         |   6 +-
>   net/openvswitch/vport.c              |   6 +-
>   net/openvswitch/vport.h              |   1 -
>   17 files changed, 483 insertions(+), 213 deletions(-)
> _______________________________________________
> dev mailing list
> dev@openvswitch.org
> http://openvswitch.org/mailman/listinfo/dev
>
