From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gigaset: call module_put before restart of if_open()
Date: Fri, 17 Jun 2011 15:28:00 -0400 (EDT)
Message-ID: <20110617.152800.1945884789188813626.davem@davemloft.net>
References: <1308327913-23220-1-git-send-email-shved@ispras.ru>
	<1308327913-23220-2-git-send-email-shved@ispras.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hjlipp@web.de, tilman@imap.cc, isdn@linux-pingi.de,
	gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@ispras.ru
To: shved@ispras.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1308327913-23220-2-git-send-email-shved@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Shved <shved@ispras.ru>
Date: Fri, 17 Jun 2011 20:25:11 +0400

> if_open() calls try_module_get(), and after an attempt to lock a mutex
> the if_open() function may return -ERESTARTSYS without
> putting the module.  Then, when if_open() is executed again,
> try_module_get() is called making the reference counter of THIS_MODULE
> greater than one at successful exit from if_open().  The if_close()
> function puts the module only once, and as a result it can't be
> unloaded.
> 
> This patch adds module_put call before the return from if_open().
> 
> Found by Linux Driver Verification project (linuxtesting.org).
> 
> Signed-off-by: Pavel Shved <shved@ispras.ru>

Applied.
