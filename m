From: Nivedita Singhvi <niv@us.ibm.com>
Subject: [Fwd: [Bug 3003] New: might_sleep warning when setting up IPSec with
 IPCOMP]
Date: Fri, 02 Jul 2004 10:56:03 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40E5A1B3.2020202@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@oss.sgi.com>, christophe@saout.de
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@intercode.com.au>, akpm@osdl.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

James, Andrew,

Looks like deflate_comp_init() is not calling
__vmalloc in a kosher way.

We are not in softirq, so deflate_gfp() is going
to return GFP_KERNEL, so this is essentially
__vmalloc() with GFP_KERNEL|__GFP_HIGHMEM, PAGE_KERNEL.

Should we be using __vmalloc here, or is this a vm issue?

thanks,
Nivedita

-------- Original Message --------
Subject: [Bug 3003] New: might_sleep warning when setting up IPSec with IPCOMP
Date: Fri, 2 Jul 2004 10:32:44 -0700
From: bugme-daemon@osdl.org
To: niv@us.ibm.com

http://bugme.osdl.org/show_bug.cgi?id=3003

            Summary: might_sleep warning when setting up IPSec with IPCOMP
     Kernel Version: 2.6.7
             Status: NEW
           Severity: normal
              Owner: niv@us.ibm.com
          Submitter: christophe@saout.de
                 CC: christophe@saout.de


Linux 2.6.7 on x86, UP preempt

Using OpenSWAN for IPSec tunnel with IP-Compression enabled.

Often gives the following warning shortly after a connection has been set up:

I'm not exactly sure whether this is cryptoapi or the compression module or
IPCOMP's fault.

Jul  2 18:39:04 websrv Debug: sleeping function called from invalid context at
mm/slab.c:1994
Jul  2 18:39:04 websrv in_atomic():1, irqs_disabled():0
Jul  2 18:39:04 websrv [<c0106c37>] dump_stack+0x17/0x20
Jul  2 18:39:04 websrv [<c0118fb4>] __might_sleep+0xb4/0xe0
Jul  2 18:39:04 websrv [<c0139fbc>] kmem_cache_alloc+0x5c/0x60
Jul  2 18:39:04 websrv [<c0147bc0>] __get_vm_area+0x20/0xf0
Jul  2 18:39:04 websrv [<c0147cb4>] get_vm_area+0x24/0x30
Jul  2 18:39:04 websrv [<c0147f1c>] __vmalloc+0x3c/0x100
Jul  2 18:39:04 websrv [<c01ecdca>] deflate_comp_init+0x4a/0xf0
Jul  2 18:39:04 websrv [<c01ecf44>] deflate_compress+0x24/0x80
Jul  2 18:39:04 websrv [<c01e8a84>] crypto_compress+0x24/0x30
Jul  2 18:39:04 websrv [<c031744c>] ipcomp_compress+0x6c/0x110
Jul  2 18:39:04 websrv [<c0317681>] ipcomp_output+0xc1/0x370
Jul  2 18:39:04 websrv [<c02e684e>] dst_output+0xe/0x30
Jul  2 18:39:04 websrv [<c02d684a>] nf_hook_slow+0xfa/0x170
Jul  2 18:39:04 websrv [<c02e4d12>] ip_queue_xmit+0x452/0x540
Jul  2 18:39:04 websrv [<c02f48af>] tcp_transmit_skb+0x3ef/0x660
Jul  2 18:39:04 websrv [<c02f558b>] tcp_write_xmit+0x15b/0x2c0
Jul  2 18:39:04 websrv [<c02ea255>] tcp_sendmsg+0x4e5/0x1030
Jul  2 18:39:04 websrv [<c0309ec7>] inet_sendmsg+0x47/0x60
Jul  2 18:39:04 websrv [<c02c5fee>] sock_aio_write+0xae/0xd0
Jul  2 18:39:04 websrv [<c014d1b6>] do_sync_write+0x76/0xb0
Jul  2 18:39:04 websrv [<c014d2bb>] vfs_write+0xcb/0xf0
Jul  2 18:39:04 websrv [<c014d375>] sys_write+0x35/0x60
Jul  2 18:39:04 websrv [<c0105e3d>] sysenter_past_esp+0x52/0x71

------- You are receiving this mail because: -------
You are the assignee for the bug, or are watching the assignee.
