From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: Initialising net/ipv4/ before net/ipv6/ breaks IPv6 autoconf
	with nfsroot....
Date: Fri, 20 Feb 2004 19:02:57 +0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1077303776.427.575.camel@hades.cambridge.redhat.com>
References: <1077201499.18703.381.camel@hades.cambridge.redhat.com>
	 <20040219222253.082458cf.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040219222253.082458cf.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2004-02-19 at 22:22 -0800, David S. Miller wrote:
> On Thu, 19 Feb 2004 14:38:20 +0000
> David Woodhouse <dwmw2@infradead.org> wrote:
> 
> > Putting IPv6 before IPv4 in net/Makefile fixes it, letting it IPv6
> > register its notifiers before the IPv4 ipconfig code brings up the
> > interface.
> > 
> > Objections?
> 
> No objection.  Send me a patch.

For 2.4, which is the one I've actually tested...

===== net/Makefile 1.8 vs edited =====
--- 1.8/net/Makefile	Fri Sep 19 12:07:29 2003
+++ edited/net/Makefile	Fri Feb 20 19:02:04 2004
@@ -15,10 +15,10 @@
 
 
 subdir-$(CONFIG_NET)		+= 802 sched netlink
+subdir-$(CONFIG_IPV6)		+= ipv6
 subdir-$(CONFIG_INET)		+= ipv4
 subdir-$(CONFIG_NETFILTER)	+= ipv4/netfilter
 subdir-$(CONFIG_UNIX)		+= unix
-subdir-$(CONFIG_IPV6)		+= ipv6
 subdir-$(CONFIG_IP_SCTP)	+= sctp
 
 ifneq ($(CONFIG_IPV6),n)


-- 
dwmw2
