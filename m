From: "David S. Miller" <davem@redhat.com>
Subject: Re: Trivial cosmetic unimportant issue (urgent)
Date: Wed, 23 Jul 2003 13:19:28 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030723131928.324b1632.davem@redhat.com>
References: <000901c3514e$59697bd0$7f0a0a0a@lappy7>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Sean" <seanlkml@rogers.com>
In-Reply-To: <000901c3514e$59697bd0$7f0a0a0a@lappy7>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 23 Jul 2003 15:12:24 -0400
"Sean" <seanlkml@rogers.com> wrote:

>       Just a few days uptime and sysfs is reporting that i've transfered a _negative_ number of bytes!  Any chance this could be
> unsigned output instead?    The display is created in a common net_device_stat_show but none of the others values should go negative
> either.

This should fix it.

--- net/core/net-sysfs.c.~1~	Wed Jul 23 12:20:15 2003
+++ net/core/net-sysfs.c	Wed Jul 23 12:20:24 2003
@@ -186,7 +186,7 @@
 
 static ssize_t net_device_stat_show(unsigned long var, char *buf)
 {
-	return sprintf(buf, "%ld\n", var);
+	return sprintf(buf, "%lu\n", var);
 }
 
 /* generate a read-only statistics attribute */
