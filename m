From: Andi Kleen <ak@suse.de>
Subject: Fw: Re: Link error with linux-2.5 bk
Date: Wed, 21 Jan 2004 18:36:02 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040121183602.51901b87.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Forgot to set correct cc originally.

Begin forwarded message:

Date: Wed, 21 Jan 2004 18:20:19 +0100
From: Andi Kleen <ak@suse.de>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: mort@wildopensource.com, linux-ia64@vger.kernel.org
Subject: Re: Link error with linux-2.5 bk


On Wed, 21 Jan 2004 08:55:19 -0800
"Luck, Tony" <tony.luck@intel.com> wrote:

> >   LD      .tmp_vmlinux1
> > local symbol 0: discarded in section `.exit.text' from drivers/built-in.o
> 
> My money is on this change to drivers/net/dummy.c (clipped from diff
> between bk3 and bk4 trees).  "dummy_free_one()" is marked as __exit (so
> we'll try to discard it), but it is called by dummy_init_module().
> 
> Dropping the "__exit" will fix it (but there may be other fixes).  Copying
> Andi Kleen, as according to BitKeeper he appears to be the author of this
> change.

Yep, the __exit is wrong. Thanks, Tony.

Jeff, can you apply this patch, please? It should fix compiling in of the dummy
device. 

Thanks.

-Andi

--- linux-2.6.2rc1-amd64/drivers/net/dummy.c-o	2004-01-21 15:52:42.000000000 +0100
+++ linux-2.6.2rc1-amd64/drivers/net/dummy.c	2004-01-21 18:19:05.000000000 +0100
@@ -112,7 +112,7 @@
 	return err;
 }
 
-static void __exit dummy_free_one(int index) 
+static void dummy_free_one(int index) 
 {
 	unregister_netdev(dummies[index]);
 	free_netdev(dummies[index]);
