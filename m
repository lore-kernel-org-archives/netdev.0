From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] bond_main.c: fix device deregistration in init
 exception path
Date: Sun, 18 Sep 2005 00:25:48 -0700 (PDT)
Message-ID: <20050918.002548.92592728.davem@davemloft.net>
References: <432D0612.7070408@gmail.com>
	<20050917233224.2d4b3652.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fmalita@gmail.com, linux-kernel@vger.kernel.org,
	ctindel@users.sourceforge.net, fubar@us.ibm.com,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751317AbVIRH0B@vger.kernel.org>
To: akpm@osdl.org
In-Reply-To: <20050917233224.2d4b3652.akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@osdl.org>
Date: Sat, 17 Sep 2005 23:32:24 -0700

> The fix is solid enough, although a better comment is needed.  Let's
> let Dave decide whether that was a sane thing to go BUG over..

The fix is fine and so is the BUG() check.

Usually, you're supposed to make sure that the very last thing
you do is register_netdev(), and that all possible errors are
possible only before that call.

And that's what BOND basically does, except that it must register
multiple devices in a loop and therefore cannot follow that rule
precisely.

So I've added the patch to my tree, it's fine to do this for a
special case usage like this one.
