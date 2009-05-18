From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: ipt_MASQUERADE weirdness (consuming CPU cycles while not used)
Date: Mon, 18 May 2009 22:19:30 +0300
Message-ID: <200905182219.30216.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I have loaded pppoe (1700 users). I test one rule for short time with -j 
MASQUERADE, then removed it and reset conntrack (conntrack -F). But still i 
can see it is consuming CPU even when it is not used in any rule. Even i 
reboot server and just load rules that dont have MASQUERADE, and just load 
module - it will start consuming CPU immediately.

Here is details:

Chain PREROUTING (policy ACCEPT 8232K packets, 473M bytes)
 pkts bytes target     prot opt in     out     source               
destination
 299K   32M ACCEPT     all  --  *      *       0.0.0.0/0            
192.168.0.0/16
 161K   14M ACCEPT     all  --  *      *       0.0.0.0/0            
194.146.152.0/22
 8396  811K ACCEPT     all  --  *      *       0.0.0.0/0            10.0.0.0/8
 445K  126M ACCEPT     all  --  *      *       0.0.0.0/0            
172.16.0.0/16
 268K   17M ACCEPT     all  --  *      *       0.0.0.0/0            2.0.0.0/8
 914K   47M DNAT       tcp  --  *      *       0.0.0.0/0            0.0.0.0/0           
tcp dpt:80 to:192.168.254.2-192.168.254.7:8080
40206 2579K DNAT       udp  --  *      *       0.0.0.0/0           !1.2.3.4             
udp dpt:53 to:1.2.3.4:53

Chain POSTROUTING (policy ACCEPT 534K packets, 159M bytes)
 pkts bytes target     prot opt in     out     source               
destination
68011 7381K ACCEPT     all  --  *      *       0.0.0.0/0            
194.146.XXX.XXX/22
 268K   18M ACCEPT     all  --  *      *       0.0.0.0/0            2.2.2.0/24
1845K  119M SNAT       all  --  *      eth0    172.16.0.0/16        0.0.0.0/0           
to:194.146.XXX.XXX

Chain OUTPUT (policy ACCEPT 97383 packets, 37M bytes)
 pkts bytes target     prot opt in     out     source               
destination


defaulthost ~ # lsmod|grep MASQ
ipt_MASQUERADE          2348  0

Oprofile:

samples  %        image name               app name                 symbol 
name
163475    9.5182  libc-2.9.so              
libc-2.9.so              /lib/libc-2.9.so
65095     3.7901  vmlinux                  vmlinux                  
memory_open
64811     3.7735  ipt_MASQUERADE           ipt_MASQUERADE           device_cmp
57111     3.3252  e1000                    e1000                    e1000_intr
55725     3.2445  e1000                    e1000                    
e1000_clean

