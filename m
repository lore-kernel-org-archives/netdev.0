From: Greg KH <gregkh@suse.de>
Subject: [patch 21/30] netfilter: bridge: refcount fix
Date: Thu, 01 Oct 2009 16:31:37 -0700
Message-ID: <20091001233321.895031689@mini.kroah.org>
References: <20091001233116.947658905@mini.kroah.org>
Cc: stable-review@kernel.org, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, alan@lxorguk.ukuu.org.uk,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>, davem@davemloft.net,
	Eric Dumazet <eric.dumazet@gmail.com>
To: linux-kernel@vger.kernel.org, stable@kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756300AbZJAXiZ@vger.kernel.org>
Content-Disposition: inline; filename=netfilter-bridge-refcount-fix.patch
In-Reply-To: <20091001233504.GA17709@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


2.6.30-stable review patch.  If anyone has any objections, please let us know.

------------------
From: Patrick McHardy <kaber@trash.net>

netfilter: bridge: refcount fix

Upstream commit f3abc9b9:

commit f216f082b2b37c4943f1e7c393e2786648d48f6f
([NETFILTER]: bridge netfilter: deal with martians correctly)
added a refcount leak on in_dev.

Instead of using in_dev_get(), we can use __in_dev_get_rcu(),
as netfilter hooks are running under rcu_read_lock(), as pointed
by Patrick.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 net/bridge/br_netfilter.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -357,7 +357,7 @@ static int br_nf_pre_routing_finish(stru
 				},
 				.proto = 0,
 			};
-			struct in_device *in_dev = in_dev_get(dev);
+			struct in_device *in_dev = __in_dev_get_rcu(dev);
 
 			/* If err equals -EHOSTUNREACH the error is due to a
 			 * martian destination or due to the fact that
