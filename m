From: Jan Oravec <jan.oravec@6com.sk>
Subject: Re: [PATCH] IPv6, sit: set prefix length 64 for link-local addresses
Date: Sun, 5 Oct 2003 11:18:45 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031005091844.GA23676@wsx.ksp.sk>
References: <20030926175405.GA31498@wsx.ksp.sk> <20030926201953.3dfc67bf.davem@redhat.com>
Reply-To: Jan Oravec <jan.oravec@6com.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030926201953.3dfc67bf.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

The mail with the patch was not delivered to netdev ML for some reasons.
Resending it..

The function sit_add_v4_addrs() calls ipv6_add_addr() with plen 64 if local
endpoint of tunnel is not configured, so I do not see a reason to set plen
to 128 if local endpoint is configured.

We are running patched kernel in our test-lab for about week and it is
working fine.



On Fri, Sep 26, 2003 at 08:19:53PM -0700, David S. Miller wrote:
> On Fri, 26 Sep 2003 19:54:05 +0200
> Jan Oravec <jan.oravec@6com.sk> wrote:
> 
> > please apply the following patch.
> > 
> > It sets the prefix length 64 instead of 128 for link-local addresses on sit interfaces.
> 
> I've seen this patch before, and I remember it being rejected
> by other ipv6 developers.
> 
> Do the USAGI or other folks remember what is going on here?

--- linux/net/ipv6/addrconf.c.orig	2003-09-08 21:50:29.000000000 +0200
+++ linux/net/ipv6/addrconf.c	2003-09-26 19:37:27.000000000 +0200
@@ -1681,7 +1681,7 @@
 	}
 
 	if (addr.s6_addr32[3]) {
-		ifp = ipv6_add_addr(idev, &addr, 128, scope, IFA_F_PERMANENT);
+		ifp = ipv6_add_addr(idev, &addr, 64, scope, IFA_F_PERMANENT);
 		if (!IS_ERR(ifp)) {
 			spin_lock_bh(&ifp->lock);
 			ifp->flags &= ~IFA_F_TENTATIVE;


Best Regards,

-- 
Jan Oravec
6COM s.r.o.
http://www.6com.sk
