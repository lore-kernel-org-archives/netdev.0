From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [PATCH] Propagate error from sctp_proc_init
Date: Wed, 14 Apr 2004 15:09:47 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0404141507520.2969@localhost.localdomain>
References: <20040414134148.GC16591@suse.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20040414134148.GC16591@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The patch looks fine. Dave, could you apply it both 2.6 and 2.4 trees.
It should apply to both of them with a little fuzz.

Thanks
Sridhar

On Wed, 14 Apr 2004, Olaf Kirch wrote:

> The following patch makes sure that an error in sctp_proc_init()
> causes module initialization to fail.
>
> Olaf
> --
> Olaf Kirch     |  The Hardware Gods hate me.
> okir@suse.de   |
> ---------------+
>

--- linux-2.6.4/net/sctp/protocol.c.initfail	2004-02-19 11:36:37.000000000 +0100
+++ linux-2.6.4/net/sctp/protocol.c	2004-04-14 15:36:19.000000000 +0200
@@ -1001,7 +1001,9 @@
 		goto err_init_mibs;

 	/* Initialize proc fs directory.  */
-	sctp_proc_init();
+	status = sctp_proc_init();
+	if (status)
+		goto err_init_proc;

 	/* Initialize object count debugging.  */
 	sctp_dbg_objcnt_init();
@@ -1165,6 +1167,7 @@
 			     sizeof(struct sctp_hashbucket)));
 err_ahash_alloc:
 	sctp_dbg_objcnt_exit();
+err_init_proc:
 	sctp_proc_exit();
 	cleanup_sctp_mibs();
 err_init_mibs:
