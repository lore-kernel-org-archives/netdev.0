From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] uio-hv-generic: store physical addresses instead of
 virtual
Date: Fri, 9 Dec 2016 09:28:44 -0800
Message-ID: <20161209092844.75b73e8d@xeon-e3>
References: <20161209114456.3719619-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Stephen Hemminger <sthemmin@microsoft.com>,
        netdev@vger.kernel.org, Haiyang Zhang <haiyangz@microsoft.com>,
        linux-kernel@vger.kernel.org, devel@linuxdriverproject.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161209114456.3719619-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri,  9 Dec 2016 12:44:40 +0100
Arnd Bergmann <arnd@arndb.de> wrote:

> gcc warns about the newly added driver when phys_addr_t is wider than
> a pointer:
> 
> drivers/uio/uio_hv_generic.c: In function 'hv_uio_mmap':
> drivers/uio/uio_hv_generic.c:71:17: error: cast to pointer from integer of different size [-Werror=int-to-pointer-cast]
>     virt_to_phys((void *)info->mem[mi].addr) >> PAGE_SHIFT,
> drivers/uio/uio_hv_generic.c: In function 'hv_uio_probe':
> drivers/uio/uio_hv_generic.c:140:5: error: cast from pointer to integer of different size [-Werror=pointer-to-int-cast]
>    = (phys_addr_t)dev->channel->ringbuffer_pages;
> drivers/uio/uio_hv_generic.c:147:3: error: cast from pointer to integer of different size [-Werror=pointer-to-int-cast]
>    (phys_addr_t)vmbus_connection.int_page;
> drivers/uio/uio_hv_generic.c:153:3: error: cast from pointer to integer of different size [-Werror=pointer-to-int-cast]
>    (phys_addr_t)vmbus_connection.monitor_pages[1];
> 
> I can't see why we store a virtual address in a phys_addr_t here,
> as the only user of that variable converts it into a physical
> address anyway, so this moves the conversion to where it logically
> fits according to the types.
> 
> Fixes: 95096f2fbd10 ("uio-hv-generic: new userspace i/o driver for VMBus")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Thanks, the code was inherited from outside, and only tested on x86_64.
Not sure which platform and GCC version generates the warning, was this just W=1?

Acked-by: Stephen Hemminger <sthemmin@microsoft.com>
