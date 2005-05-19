From: Andrew Morton <akpm@osdl.org>
Subject: Re: Fw: 2.6.12-rc4-mm[12] - ULOG problem
Date: Wed, 18 May 2005 23:45:52 -0700
Message-ID: <20050518234552.4aef6d02.akpm@osdl.org>
References: <20050518202458.55a63d37.akpm@osdl.org>
	<E1DYcyg-0005fP-00@gondolin.me.apana.org.au>
	<20050518222729.007887b8.akpm@osdl.org>
	<1116484313.21310.78.camel@uganda>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@oss.sgi.com,
        "David S. Miller"
 <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: johnpol@2ka.mipt.ru
In-Reply-To: <1116484313.21310.78.camel@uganda>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
>
> On Wed, 2005-05-18 at 22:27 -0700, Andrew Morton wrote:
> > Herbert Xu <herbert@gondor.apana.org.au> wrote:
> > >
> > > Andrew Morton <akpm@osdl.org> wrote:
> > >  > 
> > >  > This is the second report of this happening.
> > >  > 
> > >  > FATAL: Error inserting ipt_ULOG (/lib/modules/2.6.12-rc4-mm1-2/kernel/net/ipv4/netfilter/ipt_ULOG.ko): Cannot allocate memory
> > 
> > Ah yes, thanks.  netlink_kernel_create() has a dumbish return-value protocol.
> > 
> > >  This probably means that someone has stolen the NETLINK_NFLOG id.
> > 
> > cn_init() uses NETLINK_NFLOG.  Peculiar.
> 
> Yep...

Bah.

> One may use "unit" module parameter to specify different socket.

Is there any reason for being able to do that?

> Should I ask David Miller to allocate new one specially for connector?

Dave?


diff -puN include/linux/netlink.h~connector-netlink-id-fix include/linux/netlink.h
--- 25/include/linux/netlink.h~connector-netlink-id-fix	2005-05-18 23:44:43.000000000 -0700
+++ 25-akpm/include/linux/netlink.h	2005-05-18 23:44:43.000000000 -0700
@@ -14,6 +14,7 @@
 #define NETLINK_SELINUX		7	/* SELinux event notifications */
 #define NETLINK_ARPD		8
 #define NETLINK_AUDIT		9	/* auditing */
+#define NETLINK_CONNECTOR	10	/* kernel connector */
 #define NETLINK_ROUTE6		11	/* af_inet6 route comm channel */
 #define NETLINK_IP6_FW		13
 #define NETLINK_DNRTMSG		14	/* DECnet routing messages */
diff -puN drivers/connector/connector.c~connector-netlink-id-fix drivers/connector/connector.c
--- 25/drivers/connector/connector.c~connector-netlink-id-fix	2005-05-18 23:44:43.000000000 -0700
+++ 25-akpm/drivers/connector/connector.c	2005-05-18 23:44:43.000000000 -0700
@@ -33,7 +33,7 @@ MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Evgeniy Polyakov <johnpol@2ka.mipt.ru>");
 MODULE_DESCRIPTION("Generic userspace <-> kernelspace connector.");
 
-static int unit = NETLINK_NFLOG;
+static int unit = NETLINK_CONNECTOR;
 static u32 cn_idx = CN_IDX_CONNECTOR;
 static u32 cn_val = CN_VAL_CONNECTOR;
 
_
