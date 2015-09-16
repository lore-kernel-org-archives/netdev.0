From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: [linux-next] oops in ip_route_input_noref
Date: Wed, 16 Sep 2015 18:24:47 +0900
Message-ID: <20150916092447.GA945@swordfish>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

4.3.0-rc1-next-20150916

oops after removal of rndis usb device

...
ffffffff8146c052:       00 
ffffffff8146c053:       0f b6 55 8a             movzbl -0x76(%rbp),%edx
ffffffff8146c057:       49 8b bf e8 01 00 00    mov    0x1e8(%r15),%rdi
ffffffff8146c05e:       45 89 d1                mov    %r10d,%r9d
ffffffff8146c061:       44 89 f6                mov    %r14d,%esi
ffffffff8146c064:       44 88 95 70 ff ff ff    mov    %r10b,-0x90(%rbp)
ffffffff8146c06b:       0f 95 c1                setne  %cl
ffffffff8146c06e:       81 ce 00 00 00 80       or     $0x80000000,%esi
ffffffff8146c074:       41 83 e1 01             and    $0x1,%r9d
ffffffff8146c078:       45 31 c0                xor    %r8d,%r8d
ffffffff8146c07b:       e8 49 d5 ff ff          callq  ffffffff814695c9 <rt_dst_alloc>
ffffffff8146c080:       48 85 c0                test   %rax,%rax
ffffffff8146c083:       49 89 c5                mov    %rax,%r13
ffffffff8146c086:       75 0a                   jne    ffffffff8146c092 <ip_route_input_noref+0xa75>
ffffffff8146c088:       bb 97 ff ff ff          mov    $0xffffff97,%ebx
ffffffff8146c08d:       e9 06 f8 ff ff          jmpq   ffffffff8146b898 <ip_route_input_noref+0x27b>
ffffffff8146c092:       48 c7 40 58 a3 95 46    movq   $0xffffffff814695a3,0x58(%rax)
ffffffff8146c099:       81 
ffffffff8146c09a:       c6 80 a2 00 00 00 01    movb   $0x1,0xa2(%rax)
ffffffff8146c0a1:       48 8b 45 98             mov    -0x68(%rbp),%rax
ffffffff8146c0a5:       44 8a 95 70 ff ff ff    mov    -0x90(%rbp),%r10b
ffffffff8146c0ac:       48 85 c0                test   %rax,%rax
ffffffff8146c0af:       74 0a                   je     ffffffff8146c0bb <ip_route_input_noref+0xa9e>
ffffffff8146c0b1:       8b 40 10                mov    0x10(%rax),%eax
^^^^^^^
ffffffff8146c0b4:       41 89 85 b0 00 00 00    mov    %eax,0xb0(%r13)
ffffffff8146c0bb:       65 ff 05 9e 54 ba 7e    incl   %gs:0x7eba549e(%rip)        # 11560 <rt_cache_stat>
ffffffff8146c0c2:       80 7d 8a 07             cmpb   $0x7,-0x76(%rbp)
ffffffff8146c0c6:       75 1a                   jne    ffffffff8146c0e2 <ip_route_input_noref+0xac5>
ffffffff8146c0c8:       41 81 a5 9c 00 00 00    andl   $0x7fffffff,0x9c(%r13)
ffffffff8146c0cf:       ff ff ff 7f 
ffffffff8146c0d3:       f7 db                   neg    %ebx
ffffffff8146c0d5:       49 c7 45 50 b1 96 46    movq   $0xffffffff814696b1,0x50(%r13)
ffffffff8146c0dc:       81 
ffffffff8146c0dd:       66 41 89 5d 64          mov    %bx,0x64(%r13)
ffffffff8146c0e2:       45 84 d2                test   %r10b,%r10b
ffffffff8146c0e5:       74 29                   je     ffffffff8146c110 <ip_route_input_noref+0xaf3>
ffffffff8146c0e7:       0f b6 7d 89             movzbl -0x77(%rbp),%edi
ffffffff8146c0eb:       4c 89 ee                mov    %r13,%rsi
ffffffff8146c0ee:       48 ff c7                inc    %rdi
ffffffff8146c0f1:       48 6b ff 60             imul   $0x60,%rdi,%rdi
ffffffff8146c0f5:       48 03 7d 90             add    -0x70(%rbp),%rdi
ffffffff8146c0f9:       e8 10 d1 ff ff          callq  ffffffff8146920e <rt_cache_route>
ffffffff8146c0fe:       84 c0                   test   %al,%al
ffffffff8146c100:       75 0e                   jne    ffffffff8146c110 <ip_route_input_noref+0xaf3>
ffffffff8146c102:       66 41 83 4d 60 10       orw    $0x10,0x60(%r13)
ffffffff8146c108:       4c 89 ef                mov    %r13,%rdi
ffffffff8146c10b:       e8 7d cc ff ff          callq  ffffffff81468d8d <rt_add_uncached_list>
ffffffff8146c110:       4d 89 6c 24 58          mov    %r13,0x58(%r12)
ffffffff8146c115:       31 db                   xor    %ebx,%ebx
ffffffff8146c117:       e9 7c f7 ff ff          jmpq   ffffffff8146b898 <ip_route_input_noref+0x27b>
ffffffff8146c11c:       bb 8f ff ff ff          mov    $0xffffff8f,%ebx
ffffffff8146c121:       c6 45 8a 07             movb   $0x7,-0x76(%rbp)
ffffffff8146c125:       48 c7 45 90 00 00 00    movq   $0x0,-0x70(%rbp)
...

addr2line -e vmlinux -i 0xffffffff8146c0b1
net/ipv4/route.c:1815
net/ipv4/route.c:1905


which seems to be this line ip_route_input_noref()->ip_route_input_slow():
...
1813         rth->rt_is_input = 1;
1814         if (res.table)
1815                 rth->rt_table_id = res.table->tb_id;
1816
...


added by b7503e0cdb5dbec5d201aa69d8888c14679b5ae8

    net: Add FIB table id to rtable
    
    Add the FIB table id to rtable to make the information available for
    IPv4 as it is for IPv6.


	-ss
