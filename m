From: Nivedita Singhvi <niv@us.ibm.com>
Subject: sctp snmp mib stats in /proc/net/snmp
Date: Mon, 28 Oct 2002 15:51:14 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0210281540240.1647-100000@w-nivedita.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, <linux-net@vger.kernel.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I'm attaching a bitkeeper patch below that adds
support for the display of sctp snmp mib stats
in /proc/net/snmp. It is dependent on several
patches already submitted/accepted into the 
SCTP tree.  This patch is also slated for 
inclusion in the sourceforge linux kernel sctp 
project tree, given no objections here.

I'm posting this to netdev and linux-net in case
anyone has any issues with the /proc/net/snmp
display  altering (post feature freeze and all
that) even though I dont think that really applies 
here (or for any additional such changes in 
the near future)..

thanks,
Nivedita

This BitKeeper patch contains the following changesets:
1.814

# This is a BitKeeper patch.  What follows are the unified diffs for the
# set of deltas contained in the patch.  The rest of the patch, the part
# that BitKeeper cares about, is below these diffs.
# User:	nivedita
# Host:	w-nivedita.beaverton.ibm.com
# Root:	/home/nivedita/sctp/sc3/lksctp-2.5

#
#--- 1.4/net/ipv4/proc.c	Sun Sep 29 17:56:38 2002
#+++ 1.5/net/ipv4/proc.c	Mon Oct 28 12:41:20 2002
#@@ -49,6 +49,8 @@
# #include <linux/skbuff.h>
# #include <net/sock.h>
# #include <net/raw.h>
#+#include <net/sctp/sctp.h>	/* for sctp_statistics */
#+
# 
# static int fold_prot_inuse(struct proto *proto)
# {
#@@ -143,8 +145,13 @@
# 	for (i=0; i<offsetof(struct udp_mib, __pad)/sizeof(unsigned long); i++)
# 		len += sprintf(buffer+len, " %lu", fold_field((unsigned long*)udp_statistics, sizeof(struct udp_mib), i));
# 
#-	len += sprintf (buffer + len, "\n");
#+	len += sprintf (buffer +len,
#+		"\nSctp: CurrEstab ActiveEstabs PassiveEstabs Aborteds Shutdowns OutOfBlues ChecksumErrors OutCtrlChunks OutOrderChunks OutUnorderChunks InCtrlChunks InOrderChunks InUnorderChunks FragUsrMsgs ReasmUsrMsgs OutSCTPPacks InSCTPPacks RtoAlgorithm RtoMin RtoMax RtoInitial ValCookieLife MaxInitRetr\n"
#+		"Sctp:");
#+	for (i=0; i<offsetof(struct sctp_mib, __pad)/sizeof(unsigned long); i++)
#+                len += sprintf(buffer+len, " %lu", fold_field((unsigned long*)sctp_statistics, sizeof(struct sctp_mib), i));
# 
#+	len += sprintf (buffer + len, "\n");
# 	if (offset >= len)
# 	{
# 		*start = buffer;
#

# Diff checksum=febe7f08


# Patch vers:	1.3
# Patch type:	REGULAR

== ChangeSet ==
torvalds@athlon.transmeta.com|ChangeSet|20020205173056|16047|c1d11a41ed024864
jgrimm@touki.austin.ibm.com|ChangeSet|20021028142304|29005
D 1.814 02/10/28 12:42:00-08:00 nivedita@w-nivedita.beaverton.ibm.com +1 -0
B torvalds@athlon.transmeta.com|ChangeSet|20020205173056|16047|c1d11a41ed024864
C
c SCTP: Added SCTP SNMP stats display in /proc/net/snmp
K 30551
P ChangeSet
------------------------------------------------

0a0
> torvalds@athlon.transmeta.com|net/ipv4/proc.c|20020205173958|34679|e9623c7f3908083b nivedita@w-nivedita.beaverton.ibm.com|net/ipv4/proc.c|20021028204120|53456

== net/ipv4/proc.c ==
torvalds@athlon.transmeta.com|net/ipv4/proc.c|20020205173958|34679|e9623c7f3908083b
schoenfr@gaaertner.de|net/ipv4/proc.c|20020930005638|00910
D 1.5 02/10/28 12:41:20-08:00 nivedita@w-nivedita.beaverton.ibm.com +8 -1
B torvalds@athlon.transmeta.com|ChangeSet|20020205173056|16047|c1d11a41ed024864
C
c Added SCTP SNMP stats display support
K 53456
O -rw-rw-r--
P net/ipv4/proc.c
------------------------------------------------

I51 2
#include <net/sctp/sctp.h>	/* for sctp_statistics */
\
D146 1
I146 5
	len += sprintf (buffer +len,
		"\nSctp: CurrEstab ActiveEstabs PassiveEstabs Aborteds Shutdowns OutOfBlues ChecksumErrors OutCtrlChunks OutOrderChunks OutUnorderChunks InCtrlChunks InOrderChunks InUnorderChunks FragUsrMsgs ReasmUsrMsgs OutSCTPPacks InSCTPPacks RtoAlgorithm RtoMin RtoMax RtoInitial ValCookieLife MaxInitRetr\n"
		"Sctp:");
	for (i=0; i<offsetof(struct sctp_mib, __pad)/sizeof(unsigned long); i++)
                len += sprintf(buffer+len, " %lu", fold_field((unsigned long*)sctp_statistics, sizeof(struct sctp_mib), i));
I147 1
	len += sprintf (buffer + len, "\n");

# Patch checksum=bf9e22f6
