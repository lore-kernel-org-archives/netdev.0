From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: Tree for October 25 (netfilter/nf_conntrack_reasm)
Date: Tue, 26 Oct 2010 09:09:45 -0700 (PDT)
Message-ID: <20101026.090945.112602190.davem@davemloft.net>
References: <20101025145834.9b68e026.sfr@canb.auug.org.au>
	<20101025165529.9cedfeac.randy.dunlap@oracle.com>
	<20101025.220316.39174493.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: randy.dunlap@oracle.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20101025.220316.39174493.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Mon, 25 Oct 2010 22:03:16 -0700 (PDT)

> From: Randy Dunlap <randy.dunlap@oracle.com>
> Date: Mon, 25 Oct 2010 16:55:29 -0700
> 
>> On Mon, 25 Oct 2010 14:58:34 +1100 Stephen Rothwell wrote:
>> 
>>> Hi all,
>>> 
>>> Reminder: do not add 2.6.38 destined stuff to linux-next until after
>>> 2.6.37-rc1 is released.
>> 
>> net/ipv6/netfilter/nf_conntrack_reasm.c:628: error: 'nf_ct_frag6_sysctl_header' undeclared (first use in this function)
>> net/ipv6/netfilter/nf_conntrack_reasm.c:628: error: 'nf_net_netfilter_sysctl_path' undeclared (first use in this function)
>> net/ipv6/netfilter/nf_conntrack_reasm.c:629: error: 'nf_ct_frag6_sysctl_table' undeclared (first use in this function)
>> net/ipv6/netfilter/nf_conntrack_reasm.c:640: error: 'nf_ct_frag6_sysctl_header' undeclared (first use in this function)
>> 
>> 
>> config file is attached.
> 
> Should also be fixed by the commit I just pointed you to.

Actually it isn't :-)  I'll commit the following to fix this,
thanks!

--------------------
netfilter: Add missing CONFIG_SYSCTL checks in ipv6's nf_conntrack_reasm.c

Reported-by: Randy Dunlap <randy.dunlap@oracle.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv6/netfilter/nf_conntrack_reasm.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 489d71b..3a3f129 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -625,21 +625,24 @@ int nf_ct_frag6_init(void)
 	inet_frags_init_net(&nf_init_frags);
 	inet_frags_init(&nf_frags);
 
+#ifdef CONFIG_SYSCTL
 	nf_ct_frag6_sysctl_header = register_sysctl_paths(nf_net_netfilter_sysctl_path,
 							  nf_ct_frag6_sysctl_table);
 	if (!nf_ct_frag6_sysctl_header) {
 		inet_frags_fini(&nf_frags);
 		return -ENOMEM;
 	}
+#endif
 
 	return 0;
 }
 
 void nf_ct_frag6_cleanup(void)
 {
+#ifdef CONFIG_SYSCTL
 	unregister_sysctl_table(nf_ct_frag6_sysctl_header);
 	nf_ct_frag6_sysctl_header = NULL;
-
+#endif
 	inet_frags_fini(&nf_frags);
 
 	nf_init_frags.low_thresh = 0;
-- 
1.7.3.2
