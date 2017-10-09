From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] thunderbolt: Initialize Thunderbolt bus earlier
Date: Mon, 09 Oct 2017 10:30:57 -0700 (PDT)
Message-ID: <20171009.103057.2069299695410118368.davem@davemloft.net>
References: <20171009132234.65540-1-mika.westerberg@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andreas.noever@gmail.com, michael.jamet@intel.com,
        yehezkel.bernat@intel.com, fengguang.wu@intel.com,
        gregkh@linuxfoundation.org, andriy.shevchenko@linux.intel.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: mika.westerberg@linux.intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171009132234.65540-1-mika.westerberg@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mika Westerberg <mika.westerberg@linux.intel.com>
Date: Mon,  9 Oct 2017 16:22:34 +0300

> The 0day kbuild robot reports following crash:
 ...
> The reason is that both Thunderbolt bus and thunderbolt-net are build
> into the kernel image, and the latter is linked first because
> drivers/net comes before drivers/thunderbolt. Since both use
> module_init() thunderbolt-net ends up calling Thunderbolt bus functions
> too early triggering the above crash.
> 
> Fix this by moving Thunderbolt bus initialization to happen earlier to
> make sure all the data structures are ready when Thunderbolt service
> drivers are initialized. To be on the safe side also add a check for
> properly initialized xdomain_property_dir to tb_register_property_dir().
> 
> Reported-by: kernel test robot <fengguang.wu@intel.com>
> Signed-off-by: Mika Westerberg <mika.westerberg@linux.intel.com>

Applied to net-next, thanks.
