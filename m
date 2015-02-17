From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] vhost: support upto 509 memory regions
Date: Tue, 17 Feb 2015 10:02:42 +0100
Message-ID: <20150217090242.GA20254@redhat.com>
References: <1423842599-5174-1-git-send-email-imammedo@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	netdev@vger.kernel.org, pbonzini@redhat.com
To: Igor Mammedov <imammedo@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1423842599-5174-1-git-send-email-imammedo@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 13, 2015 at 03:49:59PM +0000, Igor Mammedov wrote:
> since commit
>  1d4e7e3 kvm: x86: increase user memory slots to 509
> 
> it became possible to use a bigger amount of memory
> slots, which is used by memory hotplug for
> registering hotplugged memory.
> However QEMU aborts if it's used with more than ~60
> pc-dimm devices and vhost-net since host kernel
> in module vhost-net refuses to accept more than 65
> memory regions.
> 
> Increasing VHOST_MEMORY_MAX_NREGIONS from 65 to 509
> to match KVM_USER_MEM_SLOTS fixes issue for vhost-net.
> 
> Signed-off-by: Igor Mammedov <imammedo@redhat.com>

This scares me a bit: each region is 32byte, we are talking
a 16K allocation that userspace can trigger.
How does kvm handle this issue?


> ---
>  drivers/vhost/vhost.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> index 2ee2826..ecbd7a4 100644
> --- a/drivers/vhost/vhost.c
> +++ b/drivers/vhost/vhost.c
> @@ -29,7 +29,7 @@
>  #include "vhost.h"
>  
>  enum {
> -	VHOST_MEMORY_MAX_NREGIONS = 64,
> +	VHOST_MEMORY_MAX_NREGIONS = 509,
>  	VHOST_MEMORY_F_LOG = 0x1,
>  };
>  
> -- 
> 1.8.3.1
