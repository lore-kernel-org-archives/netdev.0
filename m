From: David Gibson <hermes@gibson.dropbear.id.au>
Subject: Re: [PATRCH] janitor: hermes: delete verify_area call
Date: Mon, 29 Sep 2003 15:29:25 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030929052925.GA5037@zax>
References: <20030925215902.57f53822.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Randy.Dunlap" <rddunlap@osdl.org>
Content-Disposition: inline
In-Reply-To: <20030925215902.57f53822.rddunlap@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Sep 25, 2003 at 09:59:02PM -0700, Randy.Dunlap wrote:
> 
> Hi,
> Please apply to 2.6.0-test5-current.
> 
> Thanks,

Sorry, can you clarify why this verify_area() is not needed?
                                                                                
From: Domen Puncer <domen@coderock.org>
                                                                                
IMO, that verify_area wasn't needed.
                                                                                
                                                                                
                                                                                
 linux-260-t5bk12-kj-rddunlap/drivers/net/wireless/orinoco.c |    4
 ----
 1 files changed, 4 deletions(-)
                                                                                
diff -puN drivers/net/wireless/orinoco.c~net_wireless_orinoco_verify
+drivers/net/wireless/orinoco.c
---
+linux-260-t5bk12-kj/drivers/net/wireless/orinoco.c~net_wireless_orinoco_verify
+2003-09-25 16:03:17.000000000 -0700
+++ linux-260-t5bk12-kj-rddunlap/drivers/net/wireless/orinoco.c
2003-09-25
+16:03:17.000000000 -0700
@@ -3833,10 +3833,6 @@ orinoco_ioctl(struct net_device *dev, st
                                { SIOCIWLASTPRIV, 0, 0, "dump_recs" },
                        };
                                                                                
-                       err = verify_area(VERIFY_WRITE,
wrq->u.data.pointer,
+sizeof(privtab));
-                       if (err)
-                               break;
-
                        wrq->u.data.length = sizeof(privtab) /
+sizeof(privtab[0]);
                        if (copy_to_user(wrq->u.data.pointer, privtab,
+sizeof(privtab)))
                                err = -EFAULT;
                                                                                
_


-- 
David Gibson			| For every complex problem there is a
david@gibson.dropbear.id.au	| solution which is simple, neat and
				| wrong.
http://www.ozlabs.org/people/dgibson
