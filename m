From: Esben Nielsen <simlo@phys.au.dk>
Subject: Re: [patch 1/9] arcnet fixes
Date: Sat, 6 Nov 2004 21:14:50 +0100 (MET)
Message-ID: <Pine.OSF.4.05.10411062105070.21314-100000@da410.ifa.au.dk>
References: <20041029133923.66dd719f.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@redhat.com, jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20041029133923.66dd719f.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Did you ever get the patch fixing the original patch? (I send it with
command line mail a few days back, I am not so sure how master that...).
Let me try to send it from within pine but I am afraid the lines can be
bad ...

Esben

diff -Naur linux-2.6.9-arcnet/include/linux/if_ether.h linux-2.6.9-arcnet-fix/include/linux/if_ether.h
--- linux-2.6.9-arcnet/include/linux/if_ether.h 2004-10-20 21:01:05.000000000 +0200
+++ linux-2.6.9-arcnet-fix/include/linux/if_ether.h     2004-10-29 23:26:03.0000 00000 +0200
@@ -91,7 +91,7 @@
 #define ETH_P_IRDA     0x0017          /* Linux-IrDA                   */
 #define ETH_P_ECONET   0x0018          /* Acorn Econet                 */
 #define ETH_P_HDLC     0x0019          /* HDLC frames                  */
-#define ETH_P_ARCNET   0x0020          /* ArcNet                       */
+#define ETH_P_ARCNET   0x001A          /* 1A for ArcNet :-)            */
 
 /*
  *     This is an Ethernet frame header.
diff -Naur linux-2.6.9-arcnet/include/linux/net.h linux-2.6.9-arcnet-fix/include/linux/net.h
--- linux-2.6.9-arcnet/include/linux/net.h      2004-10-20 21:01:05.000000000 +0200
+++ linux-2.6.9-arcnet-fix/include/linux/net.h  2004-10-29 23:26:51.000000000 +0200
@@ -26,7 +26,7 @@
 struct poll_table_struct;
 struct inode;
 
-#define NPROTO         33              /* should be enough for now..   */
+#define NPROTO         32              /* should be enough for now..   */
 
 #define SYS_SOCKET     1               /* sys_socket(2)                */
 #define SYS_BIND       2               /* sys_bind(2)                  */




On Fri, 29 Oct 2004, Andrew Morton wrote:

> Esben Nielsen <simlo@phys.au.dk> wrote:
> >
> > > One problem with the patch though.
> >  > 
> >  > > diff -puN include/linux/if_ether.h~arcnet-fixes include/linux/if_ether.h
> >  > > --- 25/include/linux/if_ether.h~arcnet-fixes	2004-10-28 00:17:07.230704752 -0700
> >  > > +++ 25-akpm/include/linux/if_ether.h	2004-10-28 00:17:07.247702168 -0700
> >  > > @@ -91,6 +91,7 @@
> >  > >  #define ETH_P_IRDA	0x0017		/* Linux-IrDA			*/
> >  > >  #define ETH_P_ECONET	0x0018		/* Acorn Econet			*/
> >  > >  #define ETH_P_HDLC	0x0019		/* HDLC frames			*/
> >  > > +#define ETH_P_ARCNET	0x0020		/* ArcNet			*/
> >  > 
> >  > You should use 0x001a or similar, so you don't have
> >  > to do this next part of your patch, bumping NPROTO
> >  > in net.h
> >  > 
> > 
> >  Doh! I can't count in hex it seems. This would probably also mean I won't
> >  have to recompile the whole kernel but just the modules and I don't have 
> >  to reboot to make it work on a new machine - but just until somebody else
> >  picks the same protocol number ofcourse.
> > 
> >  Do I have to fix the problem and resubmit?
> 
> Yes please.  A patch relative to the previous one would be nice.
> 
