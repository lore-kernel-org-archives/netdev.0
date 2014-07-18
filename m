From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: Re: /proc/net/sockstat invalid memory accounting or memory leak in
 latest =?UTF-8?Q?kernels=3F?=
Date: Fri, 18 Jul 2014 11:12:33 +0300
Message-ID: <a927787503c2f0d71c330b879303b14f@visp.net.lb>
References: <40bc2b5fcda47d790f1fd247bc409041@visp.net.lb>
 <1405597918.10255.76.camel@edumazet-glaptop2.roam.corp.google.com>
 <37e25a5815a18a2da507a5b20b58427d@visp.net.lb>
 <1405604568.10255.80.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:44673 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754114AbaGRIMi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2014 04:12:38 -0400
Received: from hosting.visp.net.lb (localhost [127.0.0.1])
	by hosting.visp.net.lb (Postfix) with ESMTP id 89ADB481983
	for <netdev@vger.kernel.org>; Fri, 18 Jul 2014 11:12:35 +0300 (EEST)
In-Reply-To: <1405604568.10255.80.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

More updates. Now i found out how to see if tcp are under memory 
pressure mode, i guess when it is active, speed might degrade. Now 
almost all sockets are released, is it normal that tcp pressure still 
"yes" ?

balancer-backup ~ # cat /proc/net/protocols
protocol  size sockets  memory press maxhdr  slab module     cl co di ac 
io in de sh ss gs se re sp bi br ha uh gp em
PACKET    1216      0      -1   NI       0   no   kernel      n  n  n  n 
  n  n  n  n  n  n  n  n  n  n  n  n  n  n  n
ALG        624      0       0   NI       0   no   kernel      n  n  n  n 
  n  n  n  n  n  n  n  n  n  n  n  n  n  n  n
UNIX       832      1      -1   NI       0   yes  kernel      n  n  n  n 
  n  n  n  n  n  n  n  n  n  n  n  n  n  n  n
UDP-Lite   800      0      -1   NI       0   yes  kernel      y  y  y  n 
  y  y  y  n  y  y  y  y  y  n  y  y  y  y  n
PING       760      0      -1   NI       0   yes  kernel      y  y  y  n 
  n  y  n  n  y  y  y  y  n  y  y  y  y  y  n
RAW        768      0      -1   NI       0   yes  kernel      y  y  y  n 
  y  y  y  n  y  y  y  y  n  y  y  y  y  n  n
UDP        800      1       0   NI       0   yes  kernel      y  y  y  n 
  y  n  y  n  y  y  y  y  y  n  y  y  y  y  n
TCP       1608     24  1823119   yes    208   yes  kernel      y  y  y  
y  y  y  y  y  y  y  y  y  y  n  y  y  y  y  y
NETLINK    992      0      -1   NI       0   no   kernel      n  n  n  n 
  n  n  n  n  n  n  n  n  n  n  n  n  n  n  n
balancer-backup ~ # cat /proc/net/sockstat
sockets: used 51
TCP: inuse 21 orphan 13 tw 2 alloc 21 mem 1823120
UDP: inuse 1 mem 0
UDPLITE: inuse 0
RAW: inuse 0
FRAG: inuse 0 memory

Netid  State      Recv-Q Send-Q     Local Address:Port       Peer 
Address:Port
nl     UNCONN     0      0                      0:0                      
*
nl     UNCONN     0      0                      4:0                      
*
nl     UNCONN     0      0                     10:0                      
*
nl     UNCONN     0      0                     11:0                      
*
nl     UNCONN     0      0                     15:0                      
*
nl     UNCONN     0      0                     16:0                      
*
nl     UNCONN     0      0                     18:0                      
*
nl     UNCONN     0      0                     21:0                      
*
u_str  LISTEN     0      0      /tmp/dropbear-b661327d/auth-ac4c35f5-6 
398981316                 * 0
tcp    UNCONN     0      0                      *:21084                 
*:*
          skmem:(r0,rb2304,t0,tb212992,f0,w0,o0,bl0)
tcp    LISTEN     0      10000                  *:80                    
*:*
          skmem:(r0,rb87380,t0,tb16384,f0,w0,o0,bl0)
tcp    LISTEN     0      10000                  *:8880                  
*:*
          skmem:(r0,rb87380,t0,tb16384,f0,w0,o0,bl0)
tcp    LISTEN     0      9                      *:8080                  
*:*
          skmem:(r0,rb87380,t0,tb16384,f0,w0,o0,bl0)
tcp    LISTEN     0      20                     *:22                    
*:*
          skmem:(r0,rb87380,t0,tb16384,f0,w0,o0,bl0)
tcp    LISTEN     0      1                      *:23                    
*:*
          skmem:(r0,rb87380,t0,tb16384,f0,w0,o0,bl0)
tcp    LISTEN     0      10000                  *:443                   
*:*
          skmem:(r0,rb87380,t0,tb16384,f0,w0,o0,bl0)
tcp    ESTAB      0      176          212.22.93.7:22       
109.110.116.35:59925
          skmem:(r0,rb359040,t0,tb46080,f3584,w4608,o0,bl0)
tcp    FIN-WAIT-1 0      27545     173.194.19.109:80         
185.4.252.44:61532
          skmem:(r0,rb359040,t0,tb46080,f0,w45056,o0,bl0)
tcp    SYN-SENT   0      1            212.22.93.7:63910     
54.225.188.51:80
          skmem:(r0,rb87380,t0,tb16384,f4294966016,w1280,o0,bl0)
tcp    FIN-WAIT-1 0      28333     151.249.89.224:80         
185.4.252.27:56892
          skmem:(r0,rb359040,t0,tb46080,f3072,w46080,o0,bl0)
tcp    FIN-WAIT-1 0      28009         2.16.61.24:80        
185.4.252.139:52608
          skmem:(r0,rb359040,t0,tb46080,f0,w45056,o0,bl0)
tcp    FIN-WAIT-1 0      21753      173.194.19.46:80        
185.4.252.214:51174
          skmem:(r0,rb359040,t0,tb46080,f1024,w35840,o0,bl0)
tcp    FIN-WAIT-1 0      28437      87.248.223.79:80        
185.4.253.107:60924
          skmem:(r0,rb359040,t0,tb46080,f3072,w46080,o0,bl0)
tcp    FIN-WAIT-1 0      46194       212.25.73.21:80        
185.4.253.107:50242
          skmem:(r0,rb359040,t0,tb78336,f0,w73728,o0,bl0)
tcp    FIN-WAIT-1 0      65001     173.194.35.119:443        
185.4.252.58:50040
          skmem:(r0,rb333440,t0,tb119808,f3584,w115200,o0,bl0)
tcp    SYN-SENT   0      1            212.22.93.7:27514     
54.225.188.51:80
          skmem:(r0,rb87380,t0,tb16384,f4294966016,w1280,o0,bl0)
tcp    FIN-WAIT-1 0      3863        198.23.87.67:443       
185.4.253.115:1693
          skmem:(r0,rb333440,t0,tb46080,f3072,w9216,o0,bl0)
tcp    SYN-SENT   0      1            212.22.93.7:24487     
54.225.188.51:80
          skmem:(r0,rb87380,t0,tb16384,f4294966016,w1280,o0,bl0)
tcp    FIN-WAIT-2 0      0         54.225.251.189:443        
185.4.253.19:49317

tcp    FIN-WAIT-2 0      0         184.173.136.67:443       
185.4.252.214:56383
          skmem:(r0,rb333440,t0,tb46080,f0,w0,o0,bl0)
tcp    SYN-SENT   0      1            212.22.93.7:7830      
54.225.188.51:80
          skmem:(r0,rb87380,t0,tb16384,f4294966016,w1280,o0,bl0)
tcp    FIN-WAIT-1 0      6042       23.200.86.144:80        
185.4.252.139:54631
          skmem:(r0,rb359040,t0,tb46080,f1792,w10496,o0,bl0)
tcp    FIN-WAIT-1 0      28961     87.248.223.141:80         
185.4.253.18:61083
          skmem:(r0,rb359040,t0,tb46080,f3072,w46080,o0,bl0)


There was many like this one (with overflow?)
tcp    SYN-SENT   0      1            212.22.93.7:7830      
54.225.188.51:80
          skmem:(r0,rb87380,t0,tb16384,f4294966016,w1280,o0,bl0)


After 5-10 minutes they disappeared, but still it is in tcp pressure 
mode:
balancer-backup ~ # ss -amn
Netid  State      Recv-Q Send-Q                                          
                    Local Address:Port                                    
                            Peer Address:Port
nl     UNCONN     0      0                                               
                                0:0                                       
                                        *
nl     UNCONN     0      0                                               
                                4:0                                       
                                        *
nl     UNCONN     0      0                                               
                               10:0                                       
                                        *
nl     UNCONN     0      0                                               
                               11:0                                       
                                        *
nl     UNCONN     0      0                                               
                               15:0                                       
                                        *
nl     UNCONN     0      0                                               
                               16:0                                       
                                        *
nl     UNCONN     0      0                                               
                               18:0                                       
                                        *
nl     UNCONN     0      0                                               
                               21:0                                       
                                        *
u_str  LISTEN     0      0                                         
/tmp/dropbear-b661327d/auth-ac4c35f5-6 398981316                         
                                                 * 0
tcp    UNCONN     0      0                                               
                                *:56684                                   
                                       *:*
          skmem:(r0,rb2304,t0,tb212992,f0,w0,o0,bl0)
tcp    LISTEN     0      10000                                           
                                *:80                                      
                                       *:*
          skmem:(r0,rb87380,t0,tb16384,f0,w0,o0,bl0)
tcp    LISTEN     0      10000                                           
                                *:8880                                    
                                       *:*
          skmem:(r0,rb87380,t0,tb16384,f0,w0,o0,bl0)
tcp    LISTEN     0      9                                               
                                *:8080                                    
                                       *:*
          skmem:(r0,rb87380,t0,tb16384,f0,w0,o0,bl0)
tcp    LISTEN     0      20                                              
                                *:22                                      
                                       *:*
          skmem:(r0,rb87380,t0,tb16384,f0,w0,o0,bl0)
tcp    LISTEN     0      1                                               
                                *:23                                      
                                       *:*
          skmem:(r0,rb87380,t0,tb16384,f0,w0,o0,bl0)
tcp    LISTEN     0      10000                                           
                                *:443                                     
                                       *:*
          skmem:(r0,rb87380,t0,tb16384,f0,w0,o0,bl0)
tcp    ESTAB      0      2688                                            
                      212.22.93.7:22                                      
                          109.110.116.35:59925
          skmem:(r0,rb359040,t2304,tb46080,f256,w16128,o0,bl0)
tcp    FIN-WAIT-1 0      21753                                           
                    173.194.19.46:80                                      
                           185.4.252.214:51174
          skmem:(r0,rb359040,t0,tb46080,f1024,w35840,o0,bl0)
tcp    FIN-WAIT-1 0      46194                                           
                     212.25.73.21:80                                      
                           185.4.253.107:50242
          skmem:(r0,rb359040,t0,tb78336,f0,w73728,o0,bl0)
tcp    FIN-WAIT-1 0      65001                                           
                   173.194.35.119:443                                     
                            185.4.252.58:50040
          skmem:(r0,rb333440,t0,tb119808,f3584,w115200,o0,bl0)
tcp    FIN-WAIT-1 0      3863                                            
                     198.23.87.67:443                                     
                           185.4.253.115:1693
          skmem:(r0,rb333440,t0,tb46080,f3072,w9216,o0,bl0)

balancer-backup ~ # cat /proc/net/protocols
protocol  size sockets  memory press maxhdr  slab module     cl co di ac 
io in de sh ss gs se re sp bi br ha uh gp em
PACKET    1216      0      -1   NI       0   no   kernel      n  n  n  n 
  n  n  n  n  n  n  n  n  n  n  n  n  n  n  n
ALG        624      0       0   NI       0   no   kernel      n  n  n  n 
  n  n  n  n  n  n  n  n  n  n  n  n  n  n  n
UNIX       832      1      -1   NI       0   yes  kernel      n  n  n  n 
  n  n  n  n  n  n  n  n  n  n  n  n  n  n  n
UDP-Lite   800      0      -1   NI       0   yes  kernel      y  y  y  n 
  y  y  y  n  y  y  y  y  y  n  y  y  y  y  n
PING       760      0      -1   NI       0   yes  kernel      y  y  y  n 
  n  y  n  n  y  y  y  y  n  y  y  y  y  y  n
RAW        768      0      -1   NI       0   yes  kernel      y  y  y  n 
  y  y  y  n  y  y  y  y  n  y  y  y  y  n  n
UDP        800      1       0   NI       0   yes  kernel      y  y  y  n 
  y  n  y  n  y  y  y  y  y  n  y  y  y  y  n
TCP       1608     15  1823049   yes    208   yes  kernel      y  y  y  
y  y  y  y  y  y  y  y  y  y  n  y  y  y  y  y
NETLINK    992      0      -1   NI       0   no   kernel      n  n  n  n 
  n  n  n  n  n  n  n  n  n  n  n  n  n  n  n

Also two warnings shown on latest stable (well almost latest, 3.15.6 
released very recently, i have 3.15.5).

[73563.552667] ------------[ cut here ]------------
[73563.552889] WARNING: CPU: 3 PID: 0 at net/core/stream.c:201 
sk_stream_kill_queues+0xff/0x104()
[73563.553308] Modules linked in: iptable_filter tcp_diag udp_diag 
inet_diag unix_diag microcode xt_tcpudp xt_mark iptable_mangle ip_tables 
x_tables 8021q garp stp mrp llc
[73563.553975] CPU: 3 PID: 0 Comm: swapper/3 Not tainted 
3.15.5-build-0007 #1
[73563.554190] Hardware name: Dell Inc. PowerEdge R710/0HYPX2, BIOS 
2.0.11 02/26/2010
[73563.559607]  0000000000000000 ffff88080f263a38 ffffffff8160054b 
0000000000000000
[73563.560029]  ffff88080f263a70 ffffffff810b4e03 ffffffff81584ed6 
ffff880093b9d480
[73563.560451]  ffff880093b9d5c8 ffff8806dcecb0a8 0000000000000000 
ffff88080f263a80
[73563.560874] Call Trace:
[73563.561080]  <IRQ>  [<ffffffff8160054b>] dump_stack+0x45/0x56
[73563.561304]  [<ffffffff810b4e03>] warn_slowpath_common+0x75/0x8e
[73563.561517]  [<ffffffff81584ed6>] ? sk_stream_kill_queues+0xff/0x104
[73563.561730]  [<ffffffff810b4ebb>] warn_slowpath_null+0x15/0x17
[73563.561943]  [<ffffffff81584ed6>] sk_stream_kill_queues+0xff/0x104
[73563.562158]  [<ffffffff815bf18a>] inet_csk_destroy_sock+0x77/0xb7
[73563.562372]  [<ffffffff815c0555>] tcp_done+0x78/0x7d
[73563.562583]  [<ffffffff815c8d2c>] tcp_reset+0x53/0x56
[73563.562795]  [<ffffffff815c8e96>] tcp_validate_incoming+0x167/0x261
[73563.563012]  [<ffffffff815c9d7c>] tcp_rcv_state_process+0x613/0xaa3
[73563.563228]  [<ffffffff815cfae3>] tcp_v4_do_rcv+0x291/0x2db
[73563.563440]  [<ffffffff815b531c>] ? inet_del_offload+0x38/0x38
[73563.563653]  [<ffffffff815d2197>] tcp_v4_rcv+0x329/0x617
[73563.563868]  [<ffffffff815b06ff>] ? nf_hook_slow+0x6a/0xfb
[73563.564080]  [<ffffffff815b53d1>] ip_local_deliver_finish+0xb5/0x125
[73563.564293]  [<ffffffff815b584f>] ip_local_deliver+0x6d/0x71
[73563.564505]  [<ffffffff815b56b3>] ip_rcv_finish+0x272/0x2b4
[73563.564717]  [<ffffffff815b5aea>] ip_rcv+0x297/0x305
[73563.564929]  [<ffffffff8158b3c3>] 
__netif_receive_skb_core+0x55b/0x5a4
[73563.565142]  [<ffffffff8158b41f>] __netif_receive_skb+0x13/0x55
[73563.565353]  [<ffffffff8158b49c>] 
netif_receive_skb_internal+0x3b/0x72
[73563.565565]  [<ffffffff8158ba45>] napi_gro_receive+0x39/0x7b
[73563.565779]  [<ffffffff813b2bd2>] bnx2_poll_work+0xf8a/0x10be
[73563.565990]  [<ffffffff815c13d1>] ? tcp_sendmsg+0x435/0xb18
[73563.566201]  [<ffffffff813b2d32>] bnx2_poll_msix+0x2c/0xae
[73563.566413]  [<ffffffff8158c133>] net_rx_action+0xc9/0x162
[73563.566628]  [<ffffffff810b846a>] __do_softirq+0xd2/0x1c3
[73563.566841]  [<ffffffff810b86b2>] irq_exit+0x3a/0x81
[73563.567059]  [<ffffffff81004021>] do_IRQ+0xb4/0xcd
[73563.567275]  [<ffffffff816061aa>] common_interrupt+0x6a/0x6a
[73563.567490]  <EOI>  [<ffffffff81559e73>] ? 
cpuidle_enter_state+0x4d/0x9e
[73563.567713]  [<ffffffff81559ee6>] cpuidle_enter+0x12/0x14
[73563.567933]  [<ffffffff810e27f7>] cpu_startup_entry+0x163/0x204
[73563.568150]  [<ffffffff810239af>] start_secondary+0x1b4/0x1b9
[73563.568366] ---[ end trace 098a1058f104bc5a ]---
[73563.568577] ------------[ cut here ]------------
[73563.568791] WARNING: CPU: 3 PID: 0 at net/ipv4/af_inet.c:153 
inet_sock_destruct+0x160/0x189()
[73563.569211] Modules linked in: iptable_filter tcp_diag udp_diag 
inet_diag unix_diag microcode xt_tcpudp xt_mark iptable_mangle ip_tables 
x_tables 8021q garp stp mrp llc
[73563.569878] CPU: 3 PID: 0 Comm: swapper/3 Tainted: G        W     
3.15.5-build-0007 #1
[73563.570300] Hardware name: Dell Inc. PowerEdge R710/0HYPX2, BIOS 
2.0.11 02/26/2010
[73563.570719]  0000000000000000 ffff88080f263b38 ffffffff8160054b 
0000000000000000
[73563.571145]  ffff88080f263b70 ffffffff810b4e03 ffffffff815e01fb 
ffff880093b9d480
[73563.571573]  ffff880093b9d5c8 ffff880093b9d4d0 0000000000000000 
ffff88080f263b80
[73563.572000] Call Trace:
[73563.572210]  <IRQ>  [<ffffffff8160054b>] dump_stack+0x45/0x56
[73563.572430]  [<ffffffff810b4e03>] warn_slowpath_common+0x75/0x8e
[73563.572646]  [<ffffffff815e01fb>] ? inet_sock_destruct+0x160/0x189
[73563.572862]  [<ffffffff810b4ebb>] warn_slowpath_null+0x15/0x17
[73563.573076]  [<ffffffff815e01fb>] inet_sock_destruct+0x160/0x189
[73563.573292]  [<ffffffff8157cb5e>] __sk_free+0x18/0xd5
[73563.573504]  [<ffffffff8157cc2e>] sk_free+0x13/0x15
[73563.573719]  [<ffffffff815d2464>] tcp_v4_rcv+0x5f6/0x617
[73563.573933]  [<ffffffff815b06ff>] ? nf_hook_slow+0x6a/0xfb
[73563.574147]  [<ffffffff815b53d1>] ip_local_deliver_finish+0xb5/0x125
[73563.574362]  [<ffffffff815b584f>] ip_local_deliver+0x6d/0x71
[73563.574576]  [<ffffffff815b56b3>] ip_rcv_finish+0x272/0x2b4
[73563.574789]  [<ffffffff815b5aea>] ip_rcv+0x297/0x305
[73563.575002]  [<ffffffff8158b3c3>] 
__netif_receive_skb_core+0x55b/0x5a4
[73563.575218]  [<ffffffff8158b41f>] __netif_receive_skb+0x13/0x55
[73563.575432]  [<ffffffff8158b49c>] 
netif_receive_skb_internal+0x3b/0x72
[73563.575650]  [<ffffffff8158ba45>] napi_gro_receive+0x39/0x7b
[73563.575866]  [<ffffffff813b2bd2>] bnx2_poll_work+0xf8a/0x10be
[73563.576083]  [<ffffffff815c13d1>] ? tcp_sendmsg+0x435/0xb18
[73563.576298]  [<ffffffff813b2d32>] bnx2_poll_msix+0x2c/0xae
[73563.576512]  [<ffffffff8158c133>] net_rx_action+0xc9/0x162
[73563.576729]  [<ffffffff810b846a>] __do_softirq+0xd2/0x1c3
[73563.576944]  [<ffffffff810b86b2>] irq_exit+0x3a/0x81
[73563.577159]  [<ffffffff81004021>] do_IRQ+0xb4/0xcd
[73563.577377]  [<ffffffff816061aa>] common_interrupt+0x6a/0x6a
[73563.577591]  <EOI>  [<ffffffff81559e73>] ? 
cpuidle_enter_state+0x4d/0x9e
[73563.577814]  [<ffffffff81559ee6>] cpuidle_enter+0x12/0x14
[73563.578029]  [<ffffffff810e27f7>] cpu_startup_entry+0x163/0x204
[73563.578246]  [<ffffffff810239af>] start_secondary+0x1b4/0x1b9
[73563.578460] ---[ end trace 098a1058f104bc5b ]---

On 2014-07-17 16:42, Eric Dumazet wrote:
> On Thu, 2014-07-17 at 16:12 +0300, Denys Fedoryshchenko wrote:
>> Well, it seems not normal. But i am not sure, is mem value means this
>> memory is allocated and not released?
> 
> mem means : sockets have forward_alloc reservations. They can use this
> amount of memory without worrying.
> 
>> If it is allocated pages, MemFree in /proc/memstat should be different
>> value.
> 
> Its not allocated pages.
> 
>> I just shut down balancer process now and bypassed all traffic, and
>> waited all(ok, almost all) sockets to close, this particular server 
>> had
>> 300k connections before test.
>> 
>> sockets: used 78
>> TCP: inuse 22 orphan 17 tw 2 alloc 22 mem 1048593
>> UDP: inuse 1 mem 0
>> UDPLITE: inuse 0
>> RAW: inuse 0
>> FRAG: inuse 0 memory 0
>> 
>> MemTotal:       32664776 kB
>> MemFree:        32462456 kB
>> MemAvailable:   32449704 kB
>> 
>> ss output:
>> 
>> Netid State      Recv-Q Send-Q
>>                                                            Local
>> Address:Port
>>                                            Peer Address:Port
>> nl    UNCONN     0      0
>> 
>> 0:0
>>                                                  *
>> nl    UNCONN     0      0
>> 
>> 4:0
>>                                                  *
>> nl    UNCONN     0      0
>> 
>> 10:0
>>                                                   *
>> nl    UNCONN     0      0
>> 
>> 11:0
>>                                                   *
>> nl    UNCONN     0      0
>> 
>> 15:0
>>                                                   *
>> nl    UNCONN     0      0
>> 
>> 16:0
>>                                                   *
>> nl    UNCONN     0      0
>> 
>> 18:0
>>                                                   *
>> nl    UNCONN     0      0
>> 
>> 21:0
>>                                                   *
>> tcp   UNCONN     0      0
>> 
>> *:49484
>>                                                 *:*
>>           skmem:(r0,rb2304,t0,tb212992,f0,w0,o0,bl0)
>> tcp   LISTEN     0      1280
>> 
>> *:8880
>>                                                 *:*
>>           skmem:(r0,rb87380,t0,tb16384,f0,w0,o0,bl0)
>> tcp   LISTEN     0      20
>> 
>> *:22
>>                                                 *:*
>>           skmem:(r0,rb87380,t0,tb16384,f0,w0,o0,bl0)
>> tcp   LISTEN     0      1
>> 
>> *:23
>>                                                 *:*
>>           skmem:(r0,rb87380,t0,tb16384,f0,w0,o0,bl0)
>> tcp   LISTEN     0      1280
>> 
>> *:443
>>                                                 *:*
>>           skmem:(r0,rb87380,t0,tb16384,f0,w0,o0,bl0)
>> tcp   FIN-WAIT-1 0      4545
>> 
>> 157.56.194.74:443
>>                                                   172.17.37.4:52473
>>           skmem:(r0,rb8192,t0,tb8192,f3072,w9216,o0,bl0)
>> tcp   ESTAB      0      3008
>> 
>> 10.0.22.22:22
>>                                             194.146.153.22:59156
>>           skmem:(r0,rb359040,t0,tb18432,f768,w11520,o0,bl0)
>> tcp   FIN-WAIT-1 0      1
>> 
>> 54.225.250.234:443
>>                                                  172.17.32.251:35969
>>           skmem:(r0,rb8192,t0,tb8192,f2816,w1280,o0,bl0)
>> tcp   FIN-WAIT-2 0      0
>> 
>> 206.53.159.203:443
>>                                                   172.17.76.10:54688
>> 
>> tcp   FIN-WAIT-2 0      0
>> 
>> 173.194.39.40:443
>>                                                 172.17.64.221:39482
>> 
>> tcp   FIN-WAIT-1 0      1
>> 
>> 69.171.235.48:443
>>                                                 172.17.32.251:52731
>>           skmem:(r0,rb8192,t0,tb8192,f4294966016,w1280,o0,bl0)
> 
> This looks bad :
> 
> f4294966016 : 0xFFFFFB00
> 
> There is a bug of some sort, that leads to overflows.
