From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] vhost-net: fall back to vmalloc if high-order
 allocation fails
Date: Fri, 25 Jan 2013 03:03:13 +0000 (UTC)
Message-ID: <kdsslg$ddn$1@ger.gmane.org>
References: <87k3r31vbc.fsf@silenus.orebokech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: kvm@vger.kernel.org
Return-path: <kvm-owner@vger.kernel.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

["Followup-To:" header set to gmane.linux.network.]
On Wed, 23 Jan 2013 at 20:46 GMT, Romain Francoise <romain@orebokech.com> wrote:
> Creating a vhost-net device allocates an object large enough (34320 bytes
> on x86-64) to trigger an order-4 allocation, which may fail if memory if
> fragmented:
>
>  libvirtd: page allocation failure: order:4, mode:0x2000d0
>  ...
>  SLAB: Unable to allocate memory on node 0 (gfp=0xd0)
>    cache: size-65536, object size: 65536, order: 4
>    node 0: slabs: 8/8, objs: 8/8, free: 0
>
> In that situation, rather than forcing the caller to use regular
> virtio-net, try to allocate the descriptor with vmalloc().
>


The real problem is vhost_net struct is really big, it
should be reduced rather than workarounded like this.


> +static void vhost_net_kvfree(void *addr)
> +{
> +	if (is_vmalloc_addr(addr))
> +		vfree(addr);
> +	else
> +		kfree(addr);
> +}
> +

This kind of stuff should really go to mm, not netdev.

