From: "Michael Kerrisk" <mtk.manpages-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Subject: RFC: Updating MSG_TRUNC documentation for datagram/netlink/unix sockets
Date: Mon, 1 Dec 2008 11:16:31 -0500
Message-ID: <cfd18e0f0812010816x4b9f3458t18944179db9e50e2@mail.gmail.com>
Reply-To: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Daniel Kabs" <dkabs-3Rif73Jvm8BBDgjK7y7TUQ@public.gmane.org>,
	"Herbert Xu" <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
To: "David Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Andi Kleen" <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org>,
	"Stephen Hemminger" <shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

I'm trying to update the description of MSG_TRUNC as an *input* flag
value for calls to recv*().  I'd appreciate it if someone could could
confirm the changes in the following patch to the recv(2) man page.

(Dave, it looks like you implemented (commit commit
b558ff799977a4eda8b3823d1cf6c1c33becb671) at least some of the parts
that I'm trying to document here...  )

Cheers,

Michael

-.TH RECV 2 2008-07-14 "Linux" "Linux Programmer's Manual"
+.TH RECV 2 2008-12-01 "Linux" "Linux Programmer's Manual"
 .SH NAME
 recv, recvfrom, recvmsg \- receive a message from a socket
 .SH SYNOPSIS
@@ -254,9 +254,18 @@ Thus, a
 subsequent receive call will return the same data.
 .TP
 .BR MSG_TRUNC " (since Linux 2.2)"
-Return the real length of the packet, even when it was longer than
-the passed buffer.
-Only valid for packet sockets.
+For raw
+.RB ( AF_PACKET ),
+Internet datagram (since Linux 2.4.27/2.6.8),
+and netlink (since Linux 2.6.22) sockets:
+return the real length of the packet or datagram,
+even when it was longer than the passed buffer.
+Not implemented for Unix domain
+.RP ( unix (7))
+sockets.
+
+For use with Internet stream sockets, see
+.BR tcp (7).
 .TP
 .BR MSG_WAITALL " (since Linux 2.2)"
 This flag requests that the operation block until the full request is
--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
