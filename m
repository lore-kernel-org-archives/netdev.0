From: "David S. Miller" <davem@redhat.com>
Subject: Re: [2.5.66-mm3+debug] traces.
Date: Fri, 04 Apr 2003 17:35:38 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030404.173538.03688224.davem@redhat.com>
References: <20030404172927.2b449167.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@digeo.com
In-Reply-To: <20030404172927.2b449167.akpm@digeo.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Andrew Morton <akpm@digeo.com>
   Date: Fri, 4 Apr 2003 17:29:27 -0800

   It is a bit worrisome that dev_kfree_skb() is now illegal if local interrupts
   are disabled.  I'd expect there to be more instances.

Why worrisome?  It's an error, and now at least we'll know
about it.  This isn't a "is now illegal", it's always been
illegal.  You simply cannot take BH locks inside of IRQ disabling
ones, this is true 2.4.x too it just doesn't BUG() on you there
(you get a potential deadlock instead).

This patch should go through the Tulip maintainer (Jeff I guess)
especially since it's a fix that belongs in 2.4.x as well.

Thanks Andrew.
