From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: sctp snmp mib stats in /proc/net/snmp
Date: Tue, 29 Oct 2002 09:21:40 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0210290912580.3213-100000@w-nivedita.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

"David S. Miller" wrote:

> I can barely parse this, please output bitkeeper patches
> in gnupatch format (pass "-tu" to bk export) when you wish
> humans to read it. :-)
> 

Ah, sorry about that, and thanks for the
tip :). Will do next time..For now, here is 
the plain diff.

thanks,
Nivedita



diff -urN linux-2.5.44/net/ipv4/proc.c linux-2.5.44sc6/net/ipv4/proc.c
--- linux-2.5.44/net/ipv4/proc.c	Fri Oct 18 21:01:08 2002
+++ linux-2.5.44sc6/net/ipv4/proc.c	Fri Oct 25 15:38:35 2002
@@ -49,6 +49,8 @@
 #include <linux/skbuff.h>
 #include <net/sock.h>
 #include <net/raw.h>
+#include <net/sctp/sctp.h>	/* for sctp_statistics */
+
 
 static int fold_prot_inuse(struct proto *proto)
 {
@@ -143,8 +145,13 @@
 	for (i=0; i<offsetof(struct udp_mib, __pad)/sizeof(unsigned long); i++)
 		len += sprintf(buffer+len, " %lu", fold_field((unsigned long*)udp_statistics, sizeof(struct udp_mib), i));
 
-	len += sprintf (buffer + len, "\n");
+	len += sprintf (buffer +len,
+		"\nSctp: CurrEstab ActiveEstabs PassiveEstabs Aborteds Shutdowns OutOfBlues ChecksumErrors OutCtrlChunks OutOrderChunks OutUnorderChunks InCtrlChunks InOrderChunks InUnorderChunks FragUsrMsgs ReasmUsrMsgs OutSCTPPacks InSCTPPacks RtoAlgorithm RtoMin RtoMax RtoInitial ValCookieLife MaxInitRetr\n"
+		"Sctp:");
+	for (i=0; i<offsetof(struct sctp_mib, __pad)/sizeof(unsigned long); i++)
+                len += sprintf(buffer+len, " %lu", fold_field((unsigned long*)sctp_statistics, sizeof(struct sctp_mib), i));
 
+	len += sprintf (buffer + len, "\n");
 	if (offset >= len)
 	{
 		*start = buffer;
