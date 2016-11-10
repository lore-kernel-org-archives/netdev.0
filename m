From: David Miller <davem@davemloft.net>
Subject: Re: [Xen PATCH] xen-netback: fix error handling output
Date: Wed, 09 Nov 2016 20:29:29 -0500 (EST)
Message-ID: <20161109.202929.1025319446990411176.davem@davemloft.net>
References: <20161108133449.1649345-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: david.vrabel@citrix.com, wei.liu2@citrix.com,
        paul.durrant@citrix.com, jgross@suse.com, filipe.manco@neclab.eu,
        xen-devel@lists.xenproject.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161108133449.1649345-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Tue,  8 Nov 2016 14:34:34 +0100

> The connect function prints an unintialized error code after an
> earlier initialization was removed:
> 
> drivers/net/xen-netback/xenbus.c: In function 'connect':
> drivers/net/xen-netback/xenbus.c:938:3: error: 'err' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> 
> This prints it as -EINVAL instead, which seems to be the most
> appropriate error code. Before the patch that caused the warning,
> this would print a positive number returned by vsscanf() instead,
> which is also wrong. We probably don't need a backport though,
> as fixing the warning here should be sufficient.
> 
> Fixes: f95842e7a9f2 ("xen: make use of xenbus_read_unsigned() in xen-netback")
> Fixes: 8d3d53b3e433 ("xen-netback: Add support for multiple queues")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

That first Fixes: commit mentioned is in neither of my trees, so I
assume it is in the Xen tree and thus this fix should get applied
there.
