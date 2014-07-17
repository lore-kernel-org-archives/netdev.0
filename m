From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: Re: /proc/net/sockstat invalid memory accounting or memory leak in
 latest =?UTF-8?Q?kernels=3F?=
Date: Thu, 17 Jul 2014 16:12:50 +0300
Message-ID: <37e25a5815a18a2da507a5b20b58427d@visp.net.lb>
References: <40bc2b5fcda47d790f1fd247bc409041@visp.net.lb>
 <1405597918.10255.76.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:44219 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750776AbaGQNMx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 09:12:53 -0400
Received: from hosting.visp.net.lb (localhost [127.0.0.1])
	by hosting.visp.net.lb (Postfix) with ESMTP id EF12B48114F
	for <netdev@vger.kernel.org>; Thu, 17 Jul 2014 16:12:50 +0300 (EEST)
In-Reply-To: <1405597918.10255.76.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Well, it seems not normal. But i am not sure, is mem value means this 
memory is allocated and not released?
If it is allocated pages, MemFree in /proc/memstat should be different 
value.
I just shut down balancer process now and bypassed all traffic, and 
waited all(ok, almost all) sockets to close, this particular server had 
300k connections before test.

sockets: used 78
TCP: inuse 22 orphan 17 tw 2 alloc 22 mem 1048593
UDP: inuse 1 mem 0
UDPLITE: inuse 0
RAW: inuse 0
FRAG: inuse 0 memory 0

MemTotal:       32664776 kB
MemFree:        32462456 kB
MemAvailable:   32449704 kB

ss output:

Netid State      Recv-Q Send-Q                                           
                                                           Local 
Address:Port                                                             
                                           Peer Address:Port
nl    UNCONN     0      0                                                
                                                                       
0:0                                                                      
                                                 *
nl    UNCONN     0      0                                                
                                                                       
4:0                                                                      
                                                 *
nl    UNCONN     0      0                                                
                                                                      
10:0                                                                     
                                                  *
nl    UNCONN     0      0                                                
                                                                      
11:0                                                                     
                                                  *
nl    UNCONN     0      0                                                
                                                                      
15:0                                                                     
                                                  *
nl    UNCONN     0      0                                                
                                                                      
16:0                                                                     
                                                  *
nl    UNCONN     0      0                                                
                                                                      
18:0                                                                     
                                                  *
nl    UNCONN     0      0                                                
                                                                      
21:0                                                                     
                                                  *
tcp   UNCONN     0      0                                                
                                                                       
*:49484                                                                  
                                                *:*
          skmem:(r0,rb2304,t0,tb212992,f0,w0,o0,bl0)
tcp   LISTEN     0      1280                                             
                                                                       
*:8880                                                                   
                                                *:*
          skmem:(r0,rb87380,t0,tb16384,f0,w0,o0,bl0)
tcp   LISTEN     0      20                                               
                                                                       
*:22                                                                     
                                                *:*
          skmem:(r0,rb87380,t0,tb16384,f0,w0,o0,bl0)
tcp   LISTEN     0      1                                                
                                                                       
*:23                                                                     
                                                *:*
          skmem:(r0,rb87380,t0,tb16384,f0,w0,o0,bl0)
tcp   LISTEN     0      1280                                             
                                                                       
*:443                                                                    
                                                *:*
          skmem:(r0,rb87380,t0,tb16384,f0,w0,o0,bl0)
tcp   FIN-WAIT-1 0      4545                                             
                                                           
157.56.194.74:443                                                        
                                                  172.17.37.4:52473
          skmem:(r0,rb8192,t0,tb8192,f3072,w9216,o0,bl0)
tcp   ESTAB      0      3008                                             
                                                              
10.0.22.22:22                                                            
                                            194.146.153.22:59156
          skmem:(r0,rb359040,t0,tb18432,f768,w11520,o0,bl0)
tcp   FIN-WAIT-1 0      1                                                
                                                          
54.225.250.234:443                                                       
                                                 172.17.32.251:35969
          skmem:(r0,rb8192,t0,tb8192,f2816,w1280,o0,bl0)
tcp   FIN-WAIT-2 0      0                                                
                                                          
206.53.159.203:443                                                       
                                                  172.17.76.10:54688

tcp   FIN-WAIT-2 0      0                                                
                                                           
173.194.39.40:443                                                        
                                                172.17.64.221:39482

tcp   FIN-WAIT-1 0      1                                                
                                                           
69.171.235.48:443                                                        
                                                172.17.32.251:52731
          skmem:(r0,rb8192,t0,tb8192,f4294966016,w1280,o0,bl0)
tcp   FIN-WAIT-2 0      0                                                
                                                           
173.194.39.38:443                                                        
                                                172.17.64.228:52013
          skmem:(r0,rb8192,t0,tb8192,f0,w0,o0,bl0)
tcp   FIN-WAIT-1 0      4645                                             
                                                            
2.16.216.121:443                                                         
                                               172.17.40.215:51985
          skmem:(r0,rb8192,t0,tb8192,f3072,w9216,o0,bl0)
tcp   FIN-WAIT-2 0      0                                                
                                                          
173.192.231.39:443                                                       
                                                  172.17.10.41:56736
          skmem:(r0,rb8192,t0,tb8192,f0,w0,o0,bl0)
tcp   FIN-WAIT-2 0      0                                                
                                                           
173.194.70.95:443                                                        
                                                172.17.64.221:59055

tcp   FIN-WAIT-2 0      0                                                
                                                            
46.33.74.129:443                                                         
                                               172.17.74.223:53207
          skmem:(r0,rb8192,t0,tb8192,f0,w0,o0,bl0)
tcp   FIN-WAIT-2 0      0                                                
                                                           
173.194.70.99:443                                                        
                                                 172.17.43.95:57045
          skmem:(r0,rb8192,t0,tb8192,f0,w0,o0,bl0)
tcp   FIN-WAIT-2 0      0                                                
                                                          
198.11.217.194:443                                                       
                                                  172.17.75.46:63384
          skmem:(r0,rb8192,t0,tb8192,f0,w0,o0,bl0)
tcp   FIN-WAIT-1 0      3601                                             
                                                             
31.13.81.33:443                                                          
                                              172.17.14.192:54971
          skmem:(r0,rb8192,t0,tb8192,f1280,w6912,o0,bl0)
tcp   FIN-WAIT-1 0      4561                                             
                                                          
174.36.208.130:443                                                       
                                                 172.17.45.227:56934
          skmem:(r0,rb8192,t0,tb8192,f3072,w9216,o0,bl0)
tcp   FIN-WAIT-2 0      0                                                
                                                           
93.186.18.171:443                                                        
                                                 172.17.38.62:57496

tcp   FIN-WAIT-2 0      0                                                
                                                          
173.194.70.104:443                                                       
                                                 172.17.70.233:42575
          skmem:(r0,rb8192,t0,tb8192,f0,w0,o0,bl0)
tcp   LAST-ACK   0      3752                                             
                                                             
31.13.93.33:443                                                          
                                               172.17.46.52:6869
          skmem:(r0,rb8192,t0,tb8192,f3072,w9216,o0,bl0)


On 2014-07-17 14:51, Eric Dumazet wrote:
> On Thu, 2014-07-17 at 13:52 +0300, Denys Fedoryshchenko wrote:
>> Hi
>> 
>> I noticed TCP transfer rate slowdown after few days of operation on
>> kernel 3.15.3, after some digging found out this:
> 
> What was previous version you were using without this problem ?
> 
>> 
>> balancer-backup ~ # cat /proc/net/sockstat
>> sockets: used 118236
>> TCP: inuse 122958 orphan 4986 tw 108010 alloc 123179 mem 1955339
>> UDP: inuse 1 mem 0
>> UDPLITE: inuse 0
>> RAW: inuse 0
>> FRAG: inuse 1 memory 2
>> 
>> after shutting down program
>> balancer-backup ~ # cat /proc/net/sockstat
>> sockets: used 47
>> TCP: inuse 10552 orphan 10547 tw 142645 alloc 10552 mem 1877061
>> UDP: inuse 0 mem 0
>> UDPLITE: inuse 0
>> RAW: inuse 0
>> FRAG: inuse 0 memory 0
>> 
>> sysctl settings:
>> net.ipv4.tcp_mem = 1767103      2045612 3068412
>> 
>> I restarted recently process, and mem value didnt changed (while 
>> because
>> it is sockets should release all memory), also it looks incorrect,
>> because at same time:
>> balancer-backup ~ # cat /proc/meminfo
>> MemTotal:       32939492 kB
>> MemFree:        29876564 kB
>> 
>> While 1955339 * 4096 should be around 8GB.
>> Probably it is just accounting issue or is it real memory leak?
>> What other info i can provide to troubleshoot this info more properly?
>> I will upgrade to 3.15.5 also now, to see if issue persist there.
> 
> I see nothing really wrong in your report.
> 
> It looks like you have a lot of sockets around after shutdown of the
> program. Each FIN-WAIT socket might consume a lot of buffers in its
> write queue, unless you use/force SO_LINGER or something.
> 
> If you try the following command, you might see how many sockets have
> outstanding data.
> 
> ss -amn
