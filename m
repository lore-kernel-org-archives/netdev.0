From: Jan Oravec <jan.oravec@6com.sk>
Subject: BUG_ON() while creating/removing ipip interfaces
Date: Sun, 5 Oct 2003 11:37:31 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031005093731.GA24023@wsx.ksp.sk>
Reply-To: Jan Oravec <jan.oravec@6com.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, davem@redhat.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,


Assume that we have application 'A' and application 'B':

A:
  cnt=0;
  while(1)
  {
    if_index=create_ipip("name%i", cnt++);
    listen_on_netlink_and_wait_for_if_destroy(if_index);
  }

B:
  for i in `seq 0 100`
  do
    iptunnel del name$i
  done

'A' is written in C so it is much faster than 'B'.

We run 'A', then 'B' (on linux-2.6.0-test5). Shortly after that this
happens:


kernel BUG at net/core/dev.c:2912!
invalid operand: 0000 [#1]
CPU:    0
EIP:    0060:[<c045ecbf>]    Not tainted
EFLAGS: 00010297
EIP is at unregister_netdevice+0x19f/0x1fc
eax: 00000001   ebx: 000089f2   ecx: c06b68e0   edx: c0f1c000
esi: c62b1c00   edi: 00000000   ebp: c62b1c00   esp: c0f1de8c
ds: 007b   es: 007b   ss: 0068
Process iptunnel (pid: 8369, threadinfo=c0f1c000 task=c3218100)
Stack: 00000025 0000000a c0f1df19 000089f2 ffffffff c04c67e6 c62b1c00 ffffffff
       00003878 00000000 0000000a ffffffff 00000004 00000000 00000292 ffffffff
       ffffffff 00000000 c016ce20 cfef7b2c 000000d0 c0317b87 c0f1df18 3f0e20e8
Call Trace:
 [<c04c67e6>] ipip_tunnel_ioctl+0x236/0x440
 [<c016ce20>] d_alloc+0x20/0x1d0
 [<c0317b87>] vsprintf+0x27/0x30
 [<c045de60>] dev_ifsioc+0x130/0x4b0
 [<c045bde1>] dev_get+0x21/0x50
 [<c045e2c0>] dev_ioctl+0xe0/0x350
 [<c0454d20>] sock_ioctl+0x0/0x260
 [<c0454e30>] sock_ioctl+0x110/0x260
 [<c0167537>] sys_ioctl+0x277/0x300
 [<c010946b>] syscall_call+0x7/0xb
 
Code: 0f 0b 60 0b 14 e1 62 c0 e9 9c fe ff ff c7 44 24 04 8f 0b 00


I have seen some recent patches for tunnel devices on netdev, but was not
able to test it yet.


Best Regards,

-- 
Jan Oravec
6COM s.r.o.
http://www.6com.sk
