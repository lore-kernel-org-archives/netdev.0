From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bug 4467] New: Debug: sleeping function called from invalid
 context at mm/slab.c:2090
Date: Sun, 10 Apr 2005 13:49:34 -0700
Message-ID: <20050410134934.0bf9d6b8.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: avvisi@spalletti.it
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


proto_register() is doing kmem_cache_create() inside write_lock().


Begin forwarded message:

Date: Sun, 10 Apr 2005 05:09:39 -0700
From: bugme-daemon@osdl.org
To: akpm@digeo.com
Subject: [Bug 4467] New: Debug: sleeping function called from invalid context at mm/slab.c:2090


http://bugme.osdl.org/show_bug.cgi?id=4467

           Summary: Debug: sleeping function called from invalid context at
                    mm/slab.c:2090
    Kernel Version: 2.6.12.rc2
            Status: NEW
          Severity: normal
             Owner: akpm@digeo.com
         Submitter: avvisi@spalletti.it


Distribution: Ubuntu 5.04
Hardware Environment: Asus M6Ne Laptop
Software Environment: gcc 3.3.5, libc6 2.3.2
Problem Description:
On startup, at ipv6 module loading dmesg prints this error:
Debug: sleeping function called from invalid context at mm/slab.c:2090
in_atomic():1, irqs_disabled():0
 [<c01160f6>] __might_sleep+0xa6/0xb0
 [<c01345dd>] load_module+0x8cd/0xb70
 [<c014463d>] kmem_cache_alloc+0x6d/0x70
 [<c0143740>] kmem_cache_create+0x100/0x5b0
 [<c02e4324>] proto_register+0xa4/0xd0
 [<e1bb00b9>] inet6_init+0x19/0x200 [ipv6]
 [<c0134a32>] sys_init_module+0x182/0x240
 [<c010319b>] sysenter_past_esp+0x54/0x75

I'll attach my config

------- You are receiving this mail because: -------
You are the assignee for the bug, or are watching the assignee.
