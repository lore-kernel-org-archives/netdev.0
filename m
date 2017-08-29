From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] irda: fix link order if IRDA is built into
 the kernel
Date: Tue, 29 Aug 2017 10:49:45 -0700 (PDT)
Message-ID: <20170829.104945.1786969849973428586.davem@davemloft.net>
References: <20170829172608.GA4700@kroah.com>
        <20170829173129.GA11029@kroah.com>
        <20170829174622.GA25926@kroah.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
        samuel@sortiz.org, linux-kernel@vger.kernel.org,
        fengguang.wu@intel.com, geert@linux-m68k.org
To: gregkh@linuxfoundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170829174622.GA25926@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Greg KH <gregkh@linuxfoundation.org>
Date: Tue, 29 Aug 2017 19:46:22 +0200

> When moving the IRDA code out of net/ into drivers/staging/irda/net, the
> link order changes when IRDA is built into the kernel.  That causes a
> kernel crash at boot time as netfilter isn't initialized yet.
> 
> To fix this, build and link the irda networking code in the same exact
> order that it was previously before the move.
> 
> Reported-by: kernel test robot <fengguang.wu@intel.com>
> Reported-by: Geert Uytterhoeven <geert@linux-m68k.org>
> Signed-off-by: Greg Kroah-Hartman gregkh@linuxfoundation.org

Greg, just change the initializer in IRDA so that it will run
after subsys_init() when built statically.

IRDA is definitely not the first pontentially statically built
thing that needs netlink up and available.
