From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.6: rxrpc compile errors with SYSCTL=n
Date: Wed, 11 Aug 2004 15:41:02 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040811224102.GU11200@holomorphy.com>
References: <20040811223225.GN26174@fs.tum.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Howells <dhowells@redhat.com>, linux-kernel@vger.kernel.org,
        davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Adrian Bunk <bunk@fs.tum.de>
Content-Disposition: inline
In-Reply-To: <20040811223225.GN26174@fs.tum.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Aug 12, 2004 at 12:32:25AM +0200, Adrian Bunk wrote:
> I'm getting tons of the following compile errors in 2.6.8-rc4-mm1 (but 
> it doesn't seem to be specific to -mm) with CONFIG_SYSCTL=n:
> <--  snip  -->
> ...
>   LD      .tmp_vmlinux1
> net/built-in.o(.text+0x154127): In function `__rxrpc_call_acks_timeout':
> : undefined reference to `rxrpc_kdebug'
> net/built-in.o(.text+0x154167): In function `__rxrpc_call_rcv_timeout':
> : undefined reference to `rxrpc_kdebug'

Does this help?


Index: mm1-2.6.8-rc4/include/rxrpc/rxrpc.h
===================================================================
--- mm1-2.6.8-rc4.orig/include/rxrpc/rxrpc.h	2004-08-11 15:27:56.589237088 -0700
+++ mm1-2.6.8-rc4/include/rxrpc/rxrpc.h	2004-08-11 15:28:12.496818768 -0700
@@ -16,10 +16,17 @@
 
 extern uint32_t rxrpc_epoch;
 
+#ifdef CONFIG_SYSCTL
 extern int rxrpc_ktrace;
 extern int rxrpc_kdebug;
 extern int rxrpc_kproto;
 extern int rxrpc_knet;
+#else
+#define rxrpc_ktrace	0
+#define rxrpc_kdebug	0
+#define rxrpc_kproto	0
+#define rxrpc_knet	0
+#endif
 
 extern int rxrpc_sysctl_init(void);
 extern void rxrpc_sysctl_cleanup(void);
