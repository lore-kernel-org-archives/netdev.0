From: Frank Pavlic <fpavlic@de.ibm.com>
Subject: [patch 1/6] s390: minor claw driver fix
Date: Wed, 22 Mar 2006 16:28:21 +0100
Message-ID: <20060322162821.6ebd9af6@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751321AbWCVP1G@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi ,
following 6 patches are for s390 network drivers claw, qeth and ctc.
tty support will be removed from the ctc network device driver , which will
happen with patch 5/6 and 6/6 . The latter one will remove two files , ctctty.c and ctctty.h .

Thanks 

Frank 

[patch 1/6] s390: minor claw driver fix

From: Frank Pavlic <fpavlic@de.ibm.com>

	use CONFIG_ARCH_S390X instead of CONFIG_64BIT in function dumpit .

Signed-off-by: Frank Pavlic <fpavlic@de.ibm.com>

diffstat:
 claw.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/s390/net/claw.c b/drivers/s390/net/claw.c
index a86436a..4687bb5 100644
--- a/drivers/s390/net/claw.c
+++ b/drivers/s390/net/claw.c
@@ -1601,7 +1601,7 @@ dumpit(char* buf, int len)
         __u32      ct, sw, rm, dup;
         char       *ptr, *rptr;
         char       tbuf[82], tdup[82];
-#if (CONFIG_64BIT)
+#if (CONFIG_ARCH_S390X)
         char       addr[22];
 #else
         char       addr[12];
@@ -1617,7 +1617,7 @@ dumpit(char* buf, int len)
         dup = 0;
         for ( ct=0; ct < len; ct++, ptr++, rptr++ )  {
                 if (sw == 0) {
-#if (CONFIG_64BIT)
+#if (CONFIG_ARCH_S390X)
                         sprintf(addr, "%16.16lX",(unsigned long)rptr);
 #else
                         sprintf(addr, "%8.8X",(__u32)rptr);
@@ -1632,7 +1632,7 @@ dumpit(char* buf, int len)
                 if (sw == 8) {
                         strcat(bhex, "  ");
                 }
-#if (CONFIG_64BIT)
+#if (CONFIG_ARCH_S390X)
                 sprintf(tbuf,"%2.2lX", (unsigned long)*ptr);
 #else
                 sprintf(tbuf,"%2.2X", (__u32)*ptr);
