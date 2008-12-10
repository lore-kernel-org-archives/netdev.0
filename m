From: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Subject: Re: linux-next: Tree for December 1 (netfilter build error)
Date: Wed, 10 Dec 2008 22:24:55 +0530
Message-ID: <20081210165455.GC6391@linux.vnet.ibm.com>
References: <20081201190827.2d02b1a5.sfr@canb.auug.org.au> <20081201115934.00ba918a.randy.dunlap@oracle.com>
Reply-To: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	netdev <netdev@vger.kernel.org>, linux-next@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	netfilter-devel@vger.kernel.org, eric@inl.fr, kaber@trash.net
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081201115934.00ba918a.randy.dunlap@oracle.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Randy Dunlap <randy.dunlap@oracle.com> [2008-12-01 11:59:34]:

> On Mon, 1 Dec 2008 19:08:27 +1100 Stephen Rothwell wrote:
> 
> > Hi all,
> > 
> > Changes since 20081128:
> > 
> > Today's tree fails the powerpc allyesconfig build.
> 
> 
> ERROR: "nfulnl_log_packet" [net/netfilter/xt_NFLOG.ko] undefined!
> 
> config attached.

	next-20081210 kernel build fails when !CONFIG_NETFILTER_NETLINK_LOG 
This was introduced by the 

commit 5f7340eff8f68f41b7e5c7ad47ec4cd1ea1afb40
Author: Eric Leblond <eric@inl.fr>
Date:   Tue Nov 4 14:21:08 2008 +0100

    netfilter: xt_NFLOG: don't call nf_log_packet in NFLOG module.
	    
the function nfulnl_log_packet is exported only if
CONFIG_NETFILTER_NETLINK_LOG is enabled, so marking the loging function
between ifdef.

I have tested the patch for build failure only

Signed-off-by: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
--
 net/netfilter/xt_NFLOG.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/xt_NFLOG.c b/net/netfilter/xt_NFLOG.c
index a57c5cf..fa814a6 100644
--- a/net/netfilter/xt_NFLOG.c
+++ b/net/netfilter/xt_NFLOG.c
@@ -32,8 +32,11 @@ nflog_tg(struct sk_buff *skb, const struct xt_target_param *par)
 	li.u.ulog.group	     = info->group;
 	li.u.ulog.qthreshold = info->threshold;
 
+#ifdef CONFIG_NETFILTER_NETLINK_LOG
 	nfulnl_log_packet(par->family, par->hooknum, skb, par->in,
 			  par->out, &li, info->prefix);
+#endif /* CONFIG_NETFILTER_NETLINK_LOG */
+
 	return XT_CONTINUE;
 }
 
-- 
Thanks & Regards,
Kamalesh Babulal,
Linux Technology Center,
IBM, ISTL.
