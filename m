From: Marcel Holtmann <marcel@holtmann.org>
Subject: Some sleeping function called from invalid context
Date: Tue, 05 Apr 2005 11:35:44 +0200
Message-ID: <1112693744.7960.2.camel@pegasus>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: Network Development Mailing List <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

while testing the latest kernel from the Bitkeeper repository, I got
some sleeping functions called from invalid context:

Freeing unused kernel memory: 180k freed
Debug: sleeping function called from invalid context at mm/slab.c:2090
in_atomic():1, irqs_disabled():0
 [<c0119936>] __might_sleep+0xa6/0xb0
 [<c014ab93>] kmem_cache_alloc+0x73/0x80
 [<c0149c0e>] kmem_cache_create+0xfe/0x630
 [<c026994d>] proto_register+0x9d/0xc0
 [<f88c901c>] af_unix_init+0x1c/0x7a [unix]
 [<c0139d62>] sys_init_module+0x1b2/0x290
 [<c0103025>] syscall_call+0x7/0xb
NET: Registered protocol family 1

Debug: sleeping function called from invalid context at mm/slab.c:2090
in_atomic():1, irqs_disabled():0
 [<c0119936>] __might_sleep+0xa6/0xb0
 [<c014ab93>] kmem_cache_alloc+0x73/0x80
 [<c0149c0e>] kmem_cache_create+0xfe/0x630
 [<c0115bed>] wake_up_process+0x1d/0x30
 [<c0126a50>] free_uid+0x20/0x90
 [<c026994d>] proto_register+0x9d/0xc0
 [<f94a70b9>] inet6_init+0x19/0x200 [ipv6]
 [<c0139d62>] sys_init_module+0x1b2/0x290
 [<c0103025>] syscall_call+0x7/0xb
NET: Registered protocol family 10

Regards

Marcel
