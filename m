From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] ax25 & netrom fixes for 2.6
Date: Tue, 12 Aug 2003 12:48:20 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030812124820.2ab57161.shemminger@osdl.org>
References: <20030812194653.A28977@jeroen.pe1rxq.ampr.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-hams@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeroen Vreeken <pe1rxq@amsat.org>
In-Reply-To: <20030812194653.A28977@jeroen.pe1rxq.ampr.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

You lost a critical fix to ax25;  it oop's if I bring up any device
then do "ifconfig -a" due to use after free.

PLEASE do some debugging with some of the kernel debugging options enabled!



 Uninitialised timer!
This is just a warning.  Your computer is OK
function=0x6b6b6b6b, data=0x6b6b6b6b
Call Trace:
 [<c012ad43>] check_timer_failed+0x73/0x75
 [<c012b297>] del_timer+0x1d/0xe8
 [<fa4f70d0>] ax25_cb_del+0x96/0xdc [ax25]
 [<c011da1d>] default_wake_function+0x0/0x2e
 [<fa4f7c21>] ax25_destroy_socket+0x1f/0x335 [ax25]
 [<c011da1d>] default_wake_function+0x0/0x2e
 [<fa4f9346>] ax25_release+0xc1/0x2c0 [ax25]
 [<c0247e08>] sock_fasync+0x190/0x363
 [<c024728b>] sock_release+0x79/0xb4
 [<c0247c61>] sock_close+0x36/0x4d
 [<c01602ec>] __fput+0x103/0x115
 [<c015e805>] filp_close+0x4b/0x74
 [<c015e8b4>] sys_close+0x86/0xf8
 [<c010b2b5>] sysenter_past_esp+0x52/0x71
                                                                                
Debug: sleeping function called from invalid context at include/linux/rwsem.h:43Call Trace:
 [<c011fb3f>] __might_sleep+0x5c/0x60
 [<c011b1b8>] do_page_fault+0x78/0x4ab
 [<c011da83>] __wake_up_common+0x38/0x57
 [<c0123170>] release_console_sem+0xfc/0x133
 [<c0122f76>] printk+0x1b6/0x25a
 [<c011b140>] do_page_fault+0x0/0x4ab
 [<c010bd91>] error_code+0x2d/0x38
 [<c012b2a7>] del_timer+0x2d/0xe8
 [<fa4f70d0>] ax25_cb_del+0x96/0xdc [ax25]
 [<c011da1d>] default_wake_function+0x0/0x2e
 [<fa4f7c21>] ax25_destroy_socket+0x1f/0x335 [ax25]
 [<c011da1d>] default_wake_function+0x0/0x2e
 [<fa4f9346>] ax25_release+0xc1/0x2c0 [ax25]
 [<c0247e08>] sock_fasync+0x190/0x363
 [<c024728b>] sock_release+0x79/0xb4
 [<c0247c61>] sock_close+0x36/0x4d
 [<c01602ec>] __fput+0x103/0x115
 [<c015e805>] filp_close+0x4b/0x74
 [<c015e8b4>] sys_close+0x86/0xf8
 [<c010b2b5>] sysenter_past_esp+0x52/0x71
                                                                                
Unable to handle kernel paging request at virtual address 6b6b6b6f
 printing eip:
c012b2a7
*pde = 00000000
Oops: 0000 [#1]
CPU:    0
EIP:    0060:[<c012b2a7>]    Not tainted
EFLAGS: 00010002
EIP is at del_timer+0x2d/0xe8
eax: 00000000   ebx: 6b6b6b6b   ecx: 00000001   edx: dead4ead
esi: 00000202   edi: f723364c   ebp: f4267ed0   esp: f4267eb4
ds: 007b   es: 007b   ss: 0068
Process ifconfig (pid: 1760, threadinfo=f4266000 task=f561a080)
Stack: f723364c fa4f70d0 f723351c c011da1d f736fc84 f723351c f736fca4 f4267f00
       fa4f7c21 f723364c f561a080 c011da1d 00100100 00000246 00000246 00000246
       f736fc84 f723351c f736fca4 f4267f30 fa4f9346 f723351c 000003a7 f736fcb0
Call Trace:
 [<fa4f70d0>] ax25_cb_del+0x96/0xdc [ax25]
 [<c011da1d>] default_wake_function+0x0/0x2e
 [<fa4f7c21>] ax25_destroy_socket+0x1f/0x335 [ax25]
 [<c011da1d>] default_wake_function+0x0/0x2e
 [<fa4f9346>] ax25_release+0xc1/0x2c0 [ax25]
 [<c0247e08>] sock_fasync+0x190/0x363
 [<c024728b>] sock_release+0x79/0xb4
 [<c0247c61>] sock_close+0x36/0x4d
 [<c01602ec>] __fput+0x103/0x115
 [<c015e805>] filp_close+0x4b/0x74
 [<c015e8b4>] sys_close+0x86/0xf8
 [<c010b2b5>] sysenter_past_esp+0x52/0x71
                                                                                
Code: 81 7b 04 ad 4e ad de 0f 85 8d 00 00 00 f0 fe 0b 0f 88 3e 0d
 <3>Slab corruption: start=f723351c, expend=f723371b, problemat=f7233658
Last user: [<fa4f70d0>](ax25_cb_del+0x96/0xdc [ax25])
Data: *************************************************************************
Next: 71 F0 2C .D0 70 4F FA 71 F0 2C .********************
slab error in check_poison_obj(): cache `size-512': object was modified after fgCall Trace:
 [<c01453b1>] check_poison_obj+0x16c/0x1ac
 [<c0147174>] __kmalloc+0x172/0x1d1
 [<c024b14e>] alloc_skb+0x48/0xe1
 [<c024b14e>] alloc_skb+0x48/0xe1
 [<c024a7c9>] sock_alloc_send_pskb+0xce/0x1f6
 [<c024a91f>] sock_alloc_send_skb+0x2e/0x32
 [<c02b5400>] unix_stream_sendmsg+0x194/0x46d
 [<c02475b9>] sock_aio_write+0xbd/0xd9
 [<c015f301>] do_sync_write+0x89/0xb4
 [<c012bcfe>] schedule_timeout+0x72/0xbb
 [<c0247bf4>] sock_poll+0x29/0x30
 [<c017481f>] sys_poll+0x228/0x27c
 [<c015f415>] vfs_write+0xe9/0x119
 [<c015f4e1>] sys_write+0x3f/0x5d
 [<c010b2b5>] sysenter_past_esp+0x52/0x71
                                                                                
