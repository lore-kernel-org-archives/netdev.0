From: "Arno J. Klaassen" <arno@heho.snv.jussieu.fr>
Subject: Re: [Bugme-new] [Bug 11752] New: Extremely low netperf	UDP_RR	throughput for nvidia MCP65
Date: 18 Oct 2008 13:36:29 +0200
Message-ID: <wpprlyuoci.fsf@heho.snv.jussieu.fr>
References: <bug-11752-10286@http.bugzilla.kernel.org/>
	<20081016134920.1492cdcc.akpm@linux-foundation.org>
	<48F7AD1A.7050309@hp.com> <wp63nrx7zk.fsf@heho.snv.jussieu.fr>
	<48F8FE18.6060005@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Ayaz Abdulla <aabdulla@nvidia.com>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shiva.jussieu.fr ([134.157.0.129]:52285 "EHLO shiva.jussieu.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751423AbYJRLg7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Oct 2008 07:36:59 -0400
In-Reply-To: <48F8FE18.6060005@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rick Jones <rick.jones2@hp.com> writes:

> Arno J. Klaassen wrote:
> > Hello,
> >
> >>Are netstat stats showing retransmissions during a TCP_STREAM test?
> > some more info :
> >   [root@localhost mcp65]# uname -a
> >   Linux localhost.localdomain 2.6.27-0.352.rc7.git1.fc10.x86_64 #1
> > SMP Tue Sep 23 21:13:29 EDT 2008 x86_64 x86_64 x86_64 GNU/Linux
> > [root@localhost ~]# ifconfig
> >   eth0      Link encap:Ethernet  HWaddr 00:1E:68:XXX
> >           inet addr:172.16.1.31  Bcast:172.16.1.255  Mask:255.255.255.0
> >           inet6 addr: XXX/64 Scope:Link                     UP
> > BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
> > RX packets:1731 errors:149 dropped:0 overruns:0 frame:149
> > TX packets:1628 errors:0 dropped:0 overruns:0 carrier:0
> > collisions:0 txqueuelen:1000
> > RX bytes:2549871 (2.4 MiB)  TX bytes:125378 (122.4 KiB)
> > Interrupt:20 Base address:0x6000
> > After some fiddling (essentially installing a netperf-rpm) :
> >   [root@localhost mcp65]# netstat -Ieth0
> > Kernel Interface table
> > Iface       MTU Met    RX-OK RX-ERR RX-DRP RX-OVR    TX-OK TX-ERR
> > TX-DRP TX-OVR Flg
> > eth0       1500   0     6347    508      0      0     5838      0
> > 0      0 BMRU
> > [root@localhost mcp65]# ethtool eth0
> > Settings for eth0:
> > Supported ports: [ MII ]
> > Supported link modes:   10baseT/Half 10baseT/Full
> > 100baseT/Half 100baseT/Full
> > 1000baseT/Full                                          Supports
> > auto-negotiation: Yes
> > Advertised link modes:  10baseT/Half 10baseT/Full
> > 100baseT/Half 100baseT/Full
> > 1000baseT/Full                                          Advertised
> > auto-negotiation: Yes
> > Speed: 1000Mb/s
> > Duplex: Full
> > Port: MII
> > PHYAD: 1
> > Transceiver: external
> > Auto-negotiation: on
> > Supports Wake-on: g
> > Wake-on: d
> > Link detected: yes
> > [root@localhost mcp65]# netperf -v -t TCP_STREAM -H 172.16.1.7
> >   TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 172.16.1.7 (172.16.1.7) port 0 AF_INET
> >    132.64
> 
> Hmm, I'm surprised that the lack of a value  following the -v was
> successful - I'll have to go back and look at the code :)  Still, I
> guess it gave you the desired "-v 0" behaviour.
> 
> >   [root@localhost mcp65]# netstat -Ieth0
> >   Kernel Interface table
> >   Iface       MTU Met    RX-OK RX-ERR RX-DRP RX-OVR    TX-OK TX-ERR TX-DRP TX-OVRFlg
> >   eth0       1500   0    84682   2933      0      0   127298      0      0      0BMRU
> > I hope this is what you asked for ...
> 
> Close enough.  I suspect that if you were to snap netstat -s -t before
> and after the netperf you'd have seen retransmissions correlated to
> those "RX-ERR" stats.  My history is such that I don't think of
> netstat for link-level stats and only think of it in the context of
> IP-layer and higher (eg tcp).
> 
> Clearly something is fubar with the rx side (well duh :).  The next
> set of stats I'd try to look at would be ethtool stats for the
> interface, eg ethtool -S eth0 and see if it shows someting more
> specific for the "RX-ERR" shown by netstat -I eth0.

OK, here it is (rx_errors_total: 10049, rx_crc_errors: 10049) :

(NB, let me know how to eventually test eventual patches/binary
modules on a life-CD; I've just limited linux kernel skills)

[root@localhost ~]# netstat -s -t 
Tcp:                              
    16 active connections openings
    0 passive connection openings 
    10 failed connection attempts 
    0 connection resets received  
    2 connections established     
    683 segments received         
    693 segments send out         
    4 segments retransmited       
    0 bad segments received.      
    14 resets sent                
UdpLite:                          
TcpExt:                           
    7 delayed acks sent           
    Quick ack mode was activated 3 times
    4 packets directly queued to recvmsg prequeue.
    2 packets directly received from prequeue     
    230 packets header predicted                  
    9 acknowledgments not containing data received
    47 predicted acknowledgments                  
    2 congestion windows recovered after partial ack
    0 TCP data loss events                          
    4 other TCP timeouts                            
    3 DSACKs sent for old packets                   
    4 DSACKs sent for out of order packets          
    1 connections reset due to unexpected data      
IpExt:                                              
    InMcastPkts: 14                                 
    OutMcastPkts: 16                                
    InBcastPkts: 22                                 
[root@localhost ~]# ethtool -S eth0
NIC statistics:                    
     tx_bytes: 86812               
     tx_zero_rexmt: 1057           
     tx_one_rexmt: 0               
     tx_many_rexmt: 0              
     tx_late_collision: 0          
     tx_fifo_errors: 0             
     tx_carrier_errors: 0          
     tx_excess_deferral: 0         
     tx_retry_error: 0             
     rx_frame_error: 0             
     rx_extra_byte: 0              
     rx_late_collision: 0          
     rx_runt: 0                    
     rx_frame_too_long: 0          
     rx_over_errors: 0             
     rx_crc_errors: 323            
     rx_frame_align_error: 0       
     rx_length_error: 0            
     rx_unicast: 1021              
     rx_multicast: 0               
     rx_broadcast: 29              
     rx_packets: 1050              
     rx_errors_total: 323          
     tx_errors_total: 0            
     tx_deferral: 0                
     tx_packets: 1057              
     rx_bytes: 1421807             
     tx_pause: 0                   
     rx_pause: 0                   
     rx_drop_frame: 0              
[root@localhost ~]# netperf -v 1 -l 60 -H 172.16.1.7 -t TCP_STREAM
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 172.16.1.7 (172.16.1.7) port 0 AF_INET                                                                 
Recv   Send    Send                                                             
Socket Socket  Message  Elapsed                                                 
Size   Size    Size     Time     Throughput                                     
bytes  bytes   bytes    secs.    10^6bits/sec                                   

3217968  16384  16384    60.00     149.06   
[root@localhost ~]# netstat -s -t 
Tcp:                              
    18 active connections openings
    0 passive connection openings 
    10 failed connection attempts 
    0 connection resets received  
    2 connections established     
    523674 segments received      
    820982 segments send out      
    4 segments retransmited       
    0 bad segments received.      
    14 resets sent                
UdpLite:                          
TcpExt:                           
    1 TCP sockets finished time wait in fast timer
    7 delayed acks sent                           
    Quick ack mode was activated 15 times         
    5 packets directly queued to recvmsg prequeue.
    2 packets directly received from prequeue     
    666 packets header predicted                  
    498190 acknowledgments not containing data received
    23392 predicted acknowledgments                    
    2 congestion windows recovered after partial ack   
    0 TCP data loss events                             
    4 other TCP timeouts                               
    15 DSACKs sent for old packets                     
    16 DSACKs sent for out of order packets            
    1 connections reset due to unexpected data         
IpExt:                                                 
    InMcastPkts: 14                                    
    OutMcastPkts: 16                                   
    InBcastPkts: 33                                    
[root@localhost ~]# ethtool -S eth0
NIC statistics:                    
     tx_bytes: 1175487542          
     tx_zero_rexmt: 821009         
     tx_one_rexmt: 0               
     tx_many_rexmt: 0              
     tx_late_collision: 0          
     tx_fifo_errors: 0             
     tx_carrier_errors: 0          
     tx_excess_deferral: 0         
     tx_retry_error: 0             
     rx_frame_error: 0             
     rx_extra_byte: 0              
     rx_late_collision: 0          
     rx_runt: 0                    
     rx_frame_too_long: 0          
     rx_over_errors: 0             
     rx_crc_errors: 9301           
     rx_frame_align_error: 0       
     rx_length_error: 0            
     rx_unicast: 523675            
     rx_multicast: 0               
     rx_broadcast: 41              
     rx_packets: 523716            
     rx_errors_total: 9301         
     tx_errors_total: 0            
     tx_deferral: 0                
     tx_packets: 821009            
     rx_bytes: 39624285            
     tx_pause: 0                   
     rx_pause: 0                   
     rx_drop_frame: 0              
[root@localhost ~]# netperf -v 1 -l 60 -H 172.16.1.7 -t TCP_RR
TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 172.16.1.7 (172.16.1.7) port 0 AF_INET                                                       
Local /Remote                                                                   
Socket Size   Request  Resp.   Elapsed  Trans.                                  
Send   Recv   Size     Size    Time     Rate                                    
bytes  Bytes  bytes    bytes   secs.    per sec                                 

16384  87380  1        1       60.00     350.52   
3217968 3217968                                   
[root@localhost ~]# netstat -s -t 
Tcp:                              
    20 active connections openings
    0 passive connection openings 
    10 failed connection attempts 
    1 connection resets received  
    2 connections established     
    545934 segments received      
    843030 segments send out      
    226 segments retransmited     
    0 bad segments received.      
    15 resets sent                
UdpLite:                          
TcpExt:                           
    3 TCP sockets finished time wait in fast timer
    9 delayed acks sent                           
    Quick ack mode was activated 22 times         
    20941 packets directly queued to recvmsg prequeue.
    190 packets directly received from backlog        
    20725 packets directly received from prequeue     
    1046 packets header predicted                     
    20913 packets header predicted and directly queued to user
    498407 acknowledgments not containing data received       
    44212 predicted acknowledgments                           
    3 congestion windows recovered after partial ack          
    0 TCP data loss events                                    
    7 timeouts after SACK recovery                            
    219 other TCP timeouts                                    
    22 DSACKs sent for old packets                            
    23 DSACKs sent for out of order packets                   
    1 connections reset due to unexpected data                
    1 connections reset due to early user close               
IpExt:                                                        
    InMcastPkts: 14                                           
    OutMcastPkts: 16                                          
    InBcastPkts: 40                                           
[root@localhost ~]# ethtool -S eth0
NIC statistics:                    
     tx_bytes: 1177080452          
     tx_zero_rexmt: 843341         
     tx_one_rexmt: 0               
     tx_many_rexmt: 0              
     tx_late_collision: 0          
     tx_fifo_errors: 0             
     tx_carrier_errors: 0          
     tx_excess_deferral: 0         
     tx_retry_error: 0             
     rx_frame_error: 0             
     rx_extra_byte: 0              
     rx_late_collision: 0          
     rx_runt: 0                    
     rx_frame_too_long: 0          
     rx_over_errors: 0             
     rx_crc_errors: 9750           
     rx_frame_align_error: 0       
     rx_length_error: 0            
     rx_unicast: 545997            
     rx_multicast: 0               
     rx_broadcast: 50              
     rx_packets: 546047            
     rx_errors_total: 9750         
     tx_errors_total: 0            
     tx_deferral: 0                
     tx_packets: 843341            
     rx_bytes: 42743567            
     tx_pause: 0                   
     rx_pause: 0                   
     rx_drop_frame: 0              
[root@localhost ~]# netperf -v 1 -l 60 -H 172.16.1.7 -t UDP_RR
UDP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 172.16.1.7 (172.16.1.7) port 0 AF_INET                                                       
Local /Remote                                                                   
Socket Size   Request  Resp.   Elapsed  Trans.                                  
Send   Recv   Size     Size    Time     Rate                                    
bytes  Bytes  bytes    bytes   secs.    per sec                                 

124928 124928 1        1       60.00       5.55   
57344  524288                                     
[root@localhost ~]# netstat -s -t 
Tcp:                              
    21 active connections openings
    0 passive connection openings 
    10 failed connection attempts 
    1 connection resets received  
    2 connections established     
    546873 segments received      
    843968 segments send out      
    226 segments retransmited     
    0 bad segments received.      
    15 resets sent                
UdpLite:                          
TcpExt:                           
    4 TCP sockets finished time wait in fast timer
    10 delayed acks sent                          
    Quick ack mode was activated 27 times         
    20941 packets directly queued to recvmsg prequeue.
    190 packets directly received from backlog        
    20725 packets directly received from prequeue     
    1323 packets header predicted                     
    20913 packets header predicted and directly queued to user
    498409 acknowledgments not containing data received       
    44213 predicted acknowledgments                           
    3 congestion windows recovered after partial ack          
    0 TCP data loss events                                    
    7 timeouts after SACK recovery                            
    219 other TCP timeouts                                    
    27 DSACKs sent for old packets                            
    29 DSACKs sent for out of order packets                   
    1 connections reset due to unexpected data                
    1 connections reset due to early user close               
IpExt:                                                        
    InMcastPkts: 14                                           
    OutMcastPkts: 16
    InBcastPkts: 47
[root@localhost ~]# ethtool -S eth0
NIC statistics:
     tx_bytes: 1177171368
     tx_zero_rexmt: 844569
     tx_one_rexmt: 0
     tx_many_rexmt: 0
     tx_late_collision: 0
     tx_fifo_errors: 0
     tx_carrier_errors: 0
     tx_excess_deferral: 0
     tx_retry_error: 0
     rx_frame_error: 0
     rx_extra_byte: 0
     rx_late_collision: 0
     rx_runt: 0
     rx_frame_too_long: 0
     rx_over_errors: 0
     rx_crc_errors: 10049
     rx_frame_align_error: 0
     rx_length_error: 0
     rx_unicast: 547225
     rx_multicast: 0
     rx_broadcast: 56
     rx_packets: 547281
     rx_errors_total: 10049
     tx_errors_total: 0
     tx_deferral: 0
     tx_packets: 844569
     rx_bytes: 44106473
     tx_pause: 0
     rx_pause: 0
     rx_drop_frame: 0
[root@localhost ~]#


Arno
