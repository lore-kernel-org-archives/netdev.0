From: Liang Qin <lqin@sce.carleton.ca>
Subject: cannot always delete IPv6 route entry in Fedora core 2 and Core 3
Date: Tue, 23 Nov 2004 10:36:02 -0500
Message-ID: <41A358E2.8090909@sce.carleton.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi there,

I'm a Ph. D student at Carleton University, Canada. I've developing 
routing protocols
on Linux.

Recently when I move code from redhat 9.0 to Fedora Core 2 and 3, I 
found out sometimes
the IPv6 route entry added previously cannot be deleted successfully. 
Finally I traced down to
the system call to the kernel and did the following experiments:

[root@localhost lqin]# route -A inet6
Kernel IPv6 routing table
Destination                                 Next 
Hop                                Flags Metric Ref    Use Iface
::1/128                                     
*                                       U     0      310       0 lo
fe80::206:25ff:fea9:b1f9/128                
*                                       U     0      0        0 lo
fe80::/64                                   
*                                       U     256    0        0 eth1
fec0::/128                                  
fec0::                                  UC    0      18       0 eth1
fec0::206:25ff:fea9:b1f9/128                
*                                       U     0      21       0 lo
fec0::/64                                   
*                                       U     256    0        0 eth1
ff00::/128                                  
ff00::                                  UC    0      15       0 eth1
ff00::/8                                    
*                                       U     256    0        0 eth1
*/0                                         
*                                       UD    256    0        0 eth1
*/0                                         
*                                       U     1024   0        0 eth1
[root@localhost lqin]# ip -6 route add fec0::206:25ff:fea9:b1fd/128 dev eth1
[root@localhost lqin]# netstat --inet6 -rn
Kernel IPv6 routing table
Destination                                 Next 
Hop                                Flags Metric Ref    Use Iface
::1/128                                     
::                                      U     0      343       0 lo
fe80::206:25ff:fea9:b1f9/128                
::                                      U     0      0        0 lo
fe80::/64                                   
::                                      U     256    0        0 eth1
fec0::206:25ff:fea9:b1f9/128                
::                                      U     0      24       0 lo
fec0::206:25ff:fea9:b1fd/128                
::                                      U     1024   0        0 eth1
fec0::/64                                   
::                                      U     256    0        0 eth1
ff00::/8                                    
::                                      U     256    0        0 eth1
fec0::/64                                   
::                                      U     256    0        0 eth1
ff00::/8                                    
::                                      U     256    0        0 eth1
::/0                                        
::                                      UD    256    0        0 eth1
::/0                                        
::                                      U     1024   0        0 eth1
::/0                                        
::                                      U     1024   0        0 eth1
[root@localhost lqin]# ip -6 route del fec0::206:25ff:fea9:b1fd/128 dev eth1
[root@localhost lqin]# netstat --inet6 -rn
Kernel IPv6 routing table
Destination                                 Next 
Hop                                Flags Metric Ref    Use Iface
::1/128                                     
::                                      U     0      391       0 lo
fe80::206:25ff:fea9:b1f9/128                
::                                      U     0      0        0 lo
fe80::/64                                   
::                                      U     256    0        0 eth1
fec0::/128                                  
fec0::                                  UC    0      6        0 eth1
fec0::206:25ff:fea9:b1f9/128                
::                                      U     0      27       0 lo
fec0::206:25ff:fea9:b1fd/128                
::                                      U     1024   0        0 eth1
fec0::/64                                   
::                                      U     256    0        0 eth1
fec0::/64                                   
::                                      U     256    0        0 eth1
ff00::/128                                  
ff00::                                  UC    0      6        0 eth1
ff00::/8                                    
::                                      U     256    0        0 eth1
::/0                                        
::                                      UD    256    0        0 eth1
::/0                                        
::                                      U     1024   0        0 eth1

It will be successfully if I use command twice in very short time (ine 1 
or 2 seconds)
ip -6 route del fec0::206:25ff:fea9:b1fd/128 dev eth1

Here eth1 is a wireless interface


I tested on two Dell tops with Fedora core 2 and 3 with the same 
problem, but on redhat 9.0,
there is no such problem at all (even with the routing protocol which I 
work on).

Thanks in advance!

Liang Qin

Ottawa, Canada
