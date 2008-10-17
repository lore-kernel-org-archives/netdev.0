From: "Arno J. Klaassen" <arno@heho.snv.jussieu.fr>
Subject: Re: [Bugme-new] [Bug 11752] New: Extremely low netperf UDP_RR	throughput for nvidia MCP65
Date: 17 Oct 2008 22:49:19 +0200
Message-ID: <wp63nrx7zk.fsf@heho.snv.jussieu.fr>
References: <bug-11752-10286@http.bugzilla.kernel.org/>
	<20081016134920.1492cdcc.akpm@linux-foundation.org>
	<48F7AD1A.7050309@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	arno@heho.snv.jussieu.fr, Ayaz Abdulla <aabdulla@nvidia.com>
To: Rick Jones <rick.jones2@hp.com>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shiva.jussieu.fr ([134.157.0.129]:64156 "EHLO shiva.jussieu.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751355AbYJQUuK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Oct 2008 16:50:10 -0400
In-Reply-To: <48F7AD1A.7050309@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hello,

> Are netstat stats showing retransmissions during a TCP_STREAM test?

some more info :

  [root@localhost mcp65]# uname -a
  Linux localhost.localdomain 2.6.27-0.352.rc7.git1.fc10.x86_64 #1 SMP Tue Sep 23 21:13:29 EDT 2008 x86_64 x86_64 x86_64 GNU/Linux                                


  [root@localhost ~]# ifconfig
  eth0      Link encap:Ethernet  HWaddr 00:1E:68:XXX
          inet addr:172.16.1.31  Bcast:172.16.1.255  Mask:255.255.255.0
          inet6 addr: XXX/64 Scope:Link           
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1           
          RX packets:1731 errors:149 dropped:0 overruns:0 frame:149    
          TX packets:1628 errors:0 dropped:0 overruns:0 carrier:0      
          collisions:0 txqueuelen:1000                                 
          RX bytes:2549871 (2.4 MiB)  TX bytes:125378 (122.4 KiB)      
          Interrupt:20 Base address:0x6000

After some fiddling (essentially installing a netperf-rpm) :

  [root@localhost mcp65]# netstat -Ieth0                                         
  Kernel Interface table                                                         
  Iface       MTU Met    RX-OK RX-ERR RX-DRP RX-OVR    TX-OK TX-ERR TX-DRP TX-OVR Flg                                                                             
  eth0       1500   0     6347    508      0      0     5838      0      0      0 BMRU                                                                            


  [root@localhost mcp65]# ethtool eth0                                            
  Settings for eth0:                                                              
        Supported ports: [ MII ]                                                
        Supported link modes:   10baseT/Half 10baseT/Full                       
                                100baseT/Half 100baseT/Full                     
                                1000baseT/Full                                  
        Supports auto-negotiation: Yes                                          
        Advertised link modes:  10baseT/Half 10baseT/Full                       
                                100baseT/Half 100baseT/Full                     
                                1000baseT/Full                                  
        Advertised auto-negotiation: Yes                                        
        Speed: 1000Mb/s                                                         
        Duplex: Full                                                            
        Port: MII                                                               
        PHYAD: 1                                                                
        Transceiver: external                                                   
        Auto-negotiation: on                                                    
        Supports Wake-on: g                                                     
        Wake-on: d                                                              
        Link detected: yes                                                      

  [root@localhost mcp65]# netperf -v -t TCP_STREAM -H 172.16.1.7
  TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 172.16.1.7 (172.16.1.7) port 0 AF_INET
   132.64
  [root@localhost mcp65]# netstat -Ieth0
  Kernel Interface table
  Iface       MTU Met    RX-OK RX-ERR RX-DRP RX-OVR    TX-OK TX-ERR TX-DRP TX-OVRFlg
  eth0       1500   0    84682   2933      0      0   127298      0      0      0BMRU


I hope this is what you asked for ...

Arno

