From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: [Fwd: [Bug 3003] New: might_sleep warning when setting up IPSec
 with IPCOMP]
Date: Fri, 02 Jul 2004 14:27:02 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40E5D326.5000509@us.ibm.com>
References: <40E5A1B3.2020202@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: James Morris <jmorris@intercode.com.au>, akpm@osdl.org,
        netdev <netdev@oss.sgi.com>, christophe@saout.de, mjbligh@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Nivedita Singhvi <niv@us.ibm.com>
In-Reply-To: <40E5A1B3.2020202@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Nivedita Singhvi wrote:

> James, Andrew,
> 
> Looks like deflate_comp_init() is not calling
> __vmalloc in a kosher way.

> Jul  2 18:39:04 websrv Debug: sleeping function called from invalid 
> context at
> mm/slab.c:1994
> Jul  2 18:39:04 websrv in_atomic():1, irqs_disabled():0
> Jul  2 18:39:04 websrv [<c0106c37>] dump_stack+0x17/0x20
> Jul  2 18:39:04 websrv [<c0118fb4>] __might_sleep+0xb4/0xe0
> Jul  2 18:39:04 websrv [<c0139fbc>] kmem_cache_alloc+0x5c/0x60
> Jul  2 18:39:04 websrv [<c0147bc0>] __get_vm_area+0x20/0xf0
> Jul  2 18:39:04 websrv [<c0147cb4>] get_vm_area+0x24/0x30
> Jul  2 18:39:04 websrv [<c0147f1c>] __vmalloc+0x3c/0x100
> Jul  2 18:39:04 websrv [<c01ecdca>] deflate_comp_init+0x4a/0xf0
> Jul  2 18:39:04 websrv [<c01ecf44>] deflate_compress+0x24/0x80
> Jul  2 18:39:04 websrv [<c01e8a84>] crypto_compress+0x24/0x30
> Jul  2 18:39:04 websrv [<c031744c>] ipcomp_compress+0x6c/0x110
> Jul  2 18:39:04 websrv [<c0317681>] ipcomp_output+0xc1/0x370

We are grabbing dst->xfrm lock in ipcomp_output(),
and have it held when we call ipcomp_compress().

Is that the issue? I don't have the crypto module
code, but in_atomic() will be true.


thanks,
Nivedita
