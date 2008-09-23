From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] e1000e: Useset_memory_ro()/set_memory_rw() to
 protect flash memory
Date: Tue, 23 Sep 2008 16:29:57 -0700 (PDT)
Message-ID: <20080923.162957.141669474.davem@davemloft.net>
References: <20080923224535.6869.76210.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, mingo@elte.hu, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jesse.brandeburg@intel.com,
	john.ronciak@intel.com, bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753684AbYIWXa3@vger.kernel.org>
In-Reply-To: <20080923224535.6869.76210.stgit@jtkirshe-mobile.jf.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 23 Sep 2008 15:45:54 -0700

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> A number of users have reported NVM corruption on various ICHx platform
> LOMs.  One possible reasons for this could be unexpected and/or malicious
> writes to the flash memory area mapped into kernel memory.  Once the
> interface is up, there should be very few reads/writes of the mapped flash
> memory.  This patch makes use of the x86 set_memory_*() functions to set
> the mapped memory read-only and temporarily set it writable only when the
> driver needs to write to it.  With the memory set read-only, any unexpected
> write will be logged with a stack dump indicating the offending code.
> 
> Since these LOMs are only on x86 ICHx platforms, it does not matter that
> this API is not yet available on other architectures, however it is
> dependent on a previous patch that exports these function name symbols.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

If the X server or similar is causing this problem, this patch won't help.

The X server maps MMIO space using mmap() in userspace, and you're only
protecting the kernel side mapping.
