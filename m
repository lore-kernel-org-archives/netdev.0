From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Fw: [Kernel-janitors] net/atm/clip.c: check kmem_cache_create() #1
Date: Wed, 4 Feb 2004 22:47:40 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040204224740.B19321@electric-eye.fr.zoreil.com>
References: <rddunlap@osdl.org> <200402041904.i14J4GRr017777@ginger.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, "Randy.Dunlap" <rddunlap@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: chas williams <chas@cmf.nrl.navy.mil>
Content-Disposition: inline
In-Reply-To: <200402041904.i14J4GRr017777@ginger.cmf.nrl.navy.mil>; from chas@cmf.nrl.navy.mil on Wed, Feb 04, 2004 at 02:04:17PM -0500
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

chas williams <chas@cmf.nrl.navy.mil> :
> randy, i think it should probably return -ENOMEM instead of -1.

One should probably apply the following patch on top of it btw.



Unbalanced call to create_proc_entry() on error path.


 net/atm/clip.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletion(-)

diff -puN net/atm/clip.c~clip-procfs-leak net/atm/clip.c
--- linux-2.6.2-rc3/net/atm/clip.c~clip-procfs-leak	2004-02-04 22:41:42.000000000 +0100
+++ linux-2.6.2-rc3-fr/net/atm/clip.c	2004-02-04 22:43:33.000000000 +0100
@@ -1021,8 +1021,10 @@ static int __init atm_clip_init(void)
 	clip_tbl.kmem_cachep = kmem_cache_create(clip_tbl.id,
 	    clip_tbl.entry_size, 0, SLAB_HWCACHE_ALIGN, NULL, NULL);
 
-	if (!clip_tbl.kmem_cachep)
+	if (!clip_tbl.kmem_cachep) {
+		remove_proc_entry("arp", atm_proc_root);
 		return -ENOMEM;
+	}
 
 	/* so neigh_ifdown() doesn't complain */
 	clip_tbl.proxy_timer.data = 0;

_
