From: James Morris <jmorris@intercode.com.au>
Subject: [PATCH] Re: Sleeping function called from illegal context at
 slab.c:1378 [2.2.22 fix]
Date: Sun, 13 Oct 2002 11:33:36 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0210131126050.16673-100000@blackbird.intercode.com.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> On Mon, 23 Sep 2002, Andrew Morton wrote:
> 
> > That's a bug in ip_fw_ctl().  It's calling convert_ipfw()
> > inside FWC_WRITE_LOCK_IRQ(&ip_fw_lock, flags);
> > 
> > But convert_ipfw() does kmalloc(GFP_KERNEL).
> > 

Hi Alan,

This is the fix for 2.2.22, please apply.


- James
-- 
James Morris
<jmorris@intercode.com.au>


diff -urN -X dontdiff linux-2.2.22.orig/net/ipv4/ip_fw.c linux-2.2.22.w1/net/ipv4/ip_fw.c
--- linux-2.2.22.orig/net/ipv4/ip_fw.c	Wed Sep 25 00:06:26 2002
+++ linux-2.2.22.w1/net/ipv4/ip_fw.c	Wed Sep 25 00:20:42 2002
@@ -1274,7 +1274,7 @@
 		return NULL;
 	}
 
-	fwkern = kmalloc(SIZEOF_STRUCT_IP_FW_KERNEL, GFP_KERNEL);
+	fwkern = kmalloc(SIZEOF_STRUCT_IP_FW_KERNEL, GFP_ATOMIC);
 	if (!fwkern) {
 		duprintf("convert_ipfw: kmalloc failed!\n");
 		*errno = ENOMEM;
