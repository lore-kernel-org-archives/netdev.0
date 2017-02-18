From: Francois Saint-Jacques <fsaintjacques-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [patch] socket.7: Document SO_INCOMING_CPU
Date: Fri, 17 Feb 2017 23:06:50 -0500
Message-ID: <CABNn7+rHfUTjMtm3Biqfx83G6Rr7pY-LuHXY=JqA6N3H_SstZg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This socket option is undocumented. Applies on the latest version
(man-pages-4.09-511).

diff --git a/man7/socket.7 b/man7/socket.7
index 3efd7a5d8..1a3ffa253 100644
--- a/man7/socket.7
+++ b/man7/socket.7
@@ -490,6 +490,26 @@ flag on a socket
 operation.
 Expects an integer boolean flag.
 .TP
+.BR SO_INCOMING_CPU " (getsockopt since Linux 3.19, setsockopt since
Linux 4.4)"
+.\" getsocktop 2c8c56e15df3d4c2af3d656e44feb18789f75837
+.\" setsocktop 70da268b569d32a9fddeea85dc18043de9d89f89
+Sets or gets the cpu affinity of a socket. Expects an integer flag.
+.sp
+.in +4n
+.nf
+int cpu = 1;
+socklen_t len = sizeof(cpu);
+setsockopt(fd, SOL_SOCKET, SO_INCOMING_CPU, &cpu, &len);
+.fi
+.in
+.sp
+The typical use case is one listener per RX queue, as the associated listener
+should only accept flows handled in softirq by the same cpu.  This provides
+optimal NUMA behavior and keep cpu caches hot.
+.TP
 .B SO_KEEPALIVE
 Enable sending of keep-alive messages on connection-oriented sockets.
 Expects an integer boolean flag.
--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
