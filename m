From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [RFC iproute2 V1 7/8] man: rdma.8: Document objects and commands
Date: Thu,  4 May 2017 21:02:15 +0300
Message-ID: <20170504180216.7665-8-leon@kernel.org>
References: <20170504180216.7665-1-leon@kernel.org>
Cc: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Jiri Pirko <jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Ariel Almog <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Ram Amrani <ram.amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        Bart Van Assche <Bart.VanAssche-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org>,
        Sagi Grimberg <sagi-NQWnxTmZq1alnMjI0IkVqw@public.gmane.org>,
        Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
        Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>,
        Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Linux RDMA <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170504180216.7665-1-leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

Signed-off-by: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 man/man8/Makefile |   3 +-
 man/man8/rdma.8   | 109 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 111 insertions(+), 1 deletion(-)
 create mode 100644 man/man8/rdma.8

diff --git a/man/man8/Makefile b/man/man8/Makefile
index f3318644..81979a07 100644
--- a/man/man8/Makefile
+++ b/man/man8/Makefile
@@ -19,7 +19,8 @@ MAN8PAGES = $(TARGETS) ip.8 arpd.8 lnstat.8 routel.8 rtacct.8 rtmon.8 rtpr.8 ss.
 	tc-simple.8 tc-skbedit.8 tc-vlan.8 tc-xt.8 tc-skbmod.8 tc-ife.8 \
 	tc-tunnel_key.8 tc-sample.8 \
 	devlink.8 devlink-dev.8 devlink-monitor.8 devlink-port.8 devlink-sb.8 \
-	ifstat.8
+	ifstat.8 \
+	rdma.8

 all: $(TARGETS)

diff --git a/man/man8/rdma.8 b/man/man8/rdma.8
new file mode 100644
index 00000000..410b3d7d
--- /dev/null
+++ b/man/man8/rdma.8
@@ -0,0 +1,109 @@
+.TH RDMA 8 "28 Mar 2017" "iproute2" "Linux"
+.SH NAME
+rdma \- RDMA tool
+.SH SYNOPSIS
+.sp
+.ad l
+.in +8
+.ti -8
+.B rdma
+.RI "[ " OPTIONS " ] " OBJECT " { " COMMAND " | "
+.BR help " }"
+.sp
+
+.ti -8
+.IR OBJECT " := { "
+.BR dev " | " link " | " protocol " | " stats " | " monitor " | " memory " | " ipoib " | " provider "}"
+.sp
+
+.ti -8
+.IR OPTIONS " := { "
+\fB\-V\fR[\fIersion\fR] }
+
+.SH OPTIONS
+
+.TP
+.BR "\-V" , " -Version"
+Print the version of the
+.B rdma
+tool and exit.
+
+.SS
+.I OBJECT
+
+.TP
+.B dev
+- RDMA device.
+
+.TP
+.B link
+- RDMA port related.
+
+.TP
+.B protocol
+- RDMA protocol.
+
+.TP
+.B monitor
+- watch for netlink messages.
+
+.TP
+.B memory
+- configure memory related operations.
+
+.TP
+.B ipoib
+- configure IPoIB.
+
+.TP
+.B provider
+- provider specific configurations.
+
+.PP
+The names of all objects may be written in full or
+abbreviated form, for example
+.B stats
+can be abbreviated as
+.B stat
+or just
+.B s.
+
+.SS
+.I COMMAND
+
+Specifies the action to perform on the object.
+The set of possible actions depends on the object type.
+As a rule, it is possible to
+.B show
+(or
+.B list
+) objects, but some objects do not allow all of these operations
+or have some additional commands. The
+.B help
+command is available for all objects. It prints
+out a list of available commands and argument syntax conventions.
+.sp
+If no command is given, some default command is assumed.
+Usually it is
+.B list
+or, if the objects of this class cannot be listed,
+.BR "help" .
+
+.SH EXIT STATUS
+Exit status is 0 if command was successful or a positive integer upon failure.
+
+.SH SEE ALSO
+.BR rdma-link (8),
+.BR rdma-protocol (8),
+.BR rdma-monitor (8),
+.BR rdma-stats (8),
+.br
+
+.SH REPORTING BUGS
+Report any bugs to the Linux RDMA mailing list
+.B <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
+where the development and maintenance is primarily done.
+You do not have to be subscribed to the list to send a message there.
+
+.SH AUTHOR
+Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
--
2.12.2

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
