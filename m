From: Andi Kleen <ak@muc.de>
Subject: Re: [PATCH] Increase snd/rcv buffers in pppoe
Date: 23 Feb 2004 11:53:59 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040223105359.GA91938@colin2.muc.de>
References: <20040222234750.GA78924@colin2.muc.de> <20040222232601.481b8c57.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@muc.de>, netdev@oss.sgi.com, mostrows@styx.uwaterloo.ca
Return-path: <netdev-bounce@oss.sgi.com>
Date: Mon, 23 Feb 2004 11:53:59 +0100
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040222232601.481b8c57.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Feb 22, 2004 at 11:26:01PM -0800, David S. Miller wrote:
> On 23 Feb 2004 00:47:50 +0100
> Andi Kleen <ak@muc.de> wrote:
> 
> > I noticed that a 64bit kernel only downloads half as fast over a PPPoE DSL
> > connection than a 32bit kernel on the same hardware. The reason seems
> > to be that PPPoE uses the default 64K snd/rcv buffers at socket creation.
> > The bigger sk_buff header size on the 64bit kernel pushed
> > the buffer into being too small and preventing good throughput.
> 
> I have no problem with this, but hey while we're at it why not do the same
> for the core defaults instead?  I see no real harm in this at all as it's
> not a pppoe specific issue.

The only issue I can think of is that it could be a problem for someone
with thousands of UDP (possible some other socket family) sockets. UDP doesn't
have the memory controls TCPs has to deal with that. Upping the defaults
to 128K could run him out of memory when many of the sockets are active
at the same time.

But increasing it to 128K is probably safe enough with the increased
memory sizes of today.  Here's a new patch.

-Andi


diff -u linux-2.6.3-averell32/include/linux/skbuff.h-o linux-2.6.3-averell32/include/linux/skbuff.h
--- linux-2.6.3-averell32/include/linux/skbuff.h-o	2004-02-19 23:28:07.000000000 +0100
+++ linux-2.6.3-averell32/include/linux/skbuff.h	2004-02-25 12:42:07.000000000 +0100
@@ -271,8 +271,8 @@
 				*end;
 };
 
-#define SK_WMEM_MAX	65535
-#define SK_RMEM_MAX	65535
+#define SK_WMEM_MAX    131072
+#define SK_RMEM_MAX	131072
 
 #ifdef __KERNEL__
 /*
