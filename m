From: "David S. Miller" <davem@redhat.com>
Subject: Re: 2.6.7-rc3: unregister_netdevice: waiting for tun0 to become
 free. Usage count = 1
Date: Wed, 16 Jun 2004 13:09:50 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040616130950.6aadde3c.davem@redhat.com>
References: <20040613121514.6b3c1c8a.davem@redhat.com>
	<E1BZeW1-0008Ny-00@gondolin.me.apana.org.au>
	<20040613234142.GA32329@gondor.apana.org.au>
	<20040613183622.3a814506.davem@redhat.com>
	<20040614015013.GA11048@gondor.apana.org.au>
	<20040613210725.70dbd016.davem@redhat.com>
	<20040614042216.GA28669@gondor.apana.org.au>
	<20040614102858.GA12343@gondor.apana.org.au>
	<20040614124402.GA28519@gondor.apana.org.au>
	<20040616193731.GB29781@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, schwab@suse.de, netdev@oss.sgi.com,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
In-Reply-To: <20040616193731.GB29781@ms2.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 16 Jun 2004 23:37:31 +0400
Alexey Kuznetsov <kuznet@ms2.inr.ac.ru> wrote:

> Anyway, the comment remains damn true and the place is still
> bug. It makes sense to think about waiting for at least one quiescent
> state after detaching the stale device from dst and real dev_put() it.
> Reference to RCU is not occasional, the job looks natural for it.

It seems a simple synchronize_kernel() would clear all the
crap no?

===== net/core/dst.c 1.18 vs edited =====
--- 1.18/net/core/dst.c	2004-06-16 10:26:56 -07:00
+++ edited/net/core/dst.c	2004-06-16 13:10:37 -07:00
@@ -243,6 +243,8 @@
 			dst->ops->ifdown(dst, unregister);
 	} while ((dst = dst->child) && dst->flags & DST_NOHASH &&
 		 dst->dev == dev);
+
+	synchronize_kernel();
 }
 
 static int dst_dev_event(struct notifier_block *this, unsigned long event, void *ptr)
