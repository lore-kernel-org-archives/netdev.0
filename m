From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: Initialising net/ipv4/ before net/ipv6/ breaks IPv6 autoconf
	with nfsroot....
Date: Fri, 20 Feb 2004 19:01:37 +0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1077303696.427.570.camel@hades.cambridge.redhat.com>
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
> If at some point we create some initialization dependency between ipv4
> and ipv6 (f.e. ipv6 init needs some ipv4 table setup) we will need to
> tread carefully to keep this from breaking.

True. For 2.6 in fact we can do it this way...

===== net/ipv4/ipconfig.c 1.35 vs edited =====
--- 1.35/net/ipv4/ipconfig.c	Wed Oct  8 01:37:44 2003
+++ edited/net/ipv4/ipconfig.c	Fri Feb 20 19:00:23 2004
@@ -1324,7 +1324,7 @@
 	return 0;
 }
 
-module_init(ip_auto_config);
+late_initcall(ip_auto_config);
 
 
 /*


-- 
dwmw2
