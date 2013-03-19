From: Fernando Luis =?ISO-8859-1?Q?V=E1zquez?= Cao
	<fernando_b1-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org>
Subject: [PATCH 2/2] man/send(2): document a long standing bug that can
 cause spurious EPERM errors
Date: Tue, 19 Mar 2013 15:52:40 +0900
Message-ID: <1363675960.4767.10.camel@nexus>
References: <1363675513.4767.6.camel@nexus>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>,
	Hirotaka Sasaki <sasaki.hirotaka-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org>
To: Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1363675513.4767.6.camel@nexus>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Subject: [PATCH 2/2] man/send(2): document a long standing bug that can cause spurious EPERM errors

This bug has been known since early 2009 (the latest) and  discussed in
netdev before:

http://marc.info/?l=linux-netdev&w=2&r=1&s=Possible+race+condition+in+conntracking+&q=b

It seems that a proper fix would be non trivial, so document the bug
in the meantime.

Reported-by: Hirotaka Sasaki <sasaki.hirotaka-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org>
Signed-off-by: Fernando Luis Vazquez Cao <fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org>
---

diff -urNp man-pages-3.50-orig/man2/send.2 man-pages-3.50/man2/send.2
--- man-pages-3.50-orig/man2/send.2	2013-03-19 15:18:03.784306647 +0900
+++ man-pages-3.50/man2/send.2	2013-03-19 15:30:40.788060426 +0900
@@ -420,6 +420,11 @@ Linux may return
 .B EPIPE
 instead of
 .BR ENOTCONN .
+
+Linux may return spurious
+.B EPERM
+errors when netfilter's conntrack module is loaded and two or more
+UDP packets belonging to the same connection are processed in parallel.
 .SH EXAMPLE
 An example of the use of
 .BR sendto ()


--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
