From: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Subject: extra spinlocking in forcedeth 0.25
Date: Wed, 24 Mar 2004 08:49:16 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <17278479577.20040324084916@port.imtp.ilyichevsk.odessa.ua>
Reply-To: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Carl-Daniel Hailfinger <c-d.hailfinger.kernel.2004@gmx.net>,
        Jeff Garzik <jgarzik@pobox.com>,
        Manfred Spraul <manfred@colorfullife.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

[I failed to find email addr of Andrew de Quincey,
who added WOL support. Feel frre to forward this to him]

In 0.23 -> 0.25 forcedeth diff I noticed this:

+       case ETHTOOL_GWOL:
+       {
+               struct ethtool_wolinfo wolinfo;
+               memset(&wolinfo, 0, sizeof(wolinfo));
+               wolinfo.supported = WAKE_MAGIC;
+
+               spin_lock_irq(&np->lock);
+               if (np->wolenabled)
+                       wolinfo.wolopts = WAKE_MAGIC;
+               spin_unlock_irq(&np->lock);
+
+               if (copy_to_user(useraddr, &wolinfo, sizeof(wolinfo)))
+                       return -EFAULT;
+               return 0;
+       }

IMHO this pair of lock()/unlock() is not needed
and can be safely removed.
-- 
vda
