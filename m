From: Alexandre DERUMIER <aderumier-U/x3PoR4x10AvxtiuMwx3w@public.gmane.org>
Subject: bridge vlan range,
 kernel 4.1 : "message truncated" warning when too much vlans defined
Date: Wed, 29 Jul 2015 20:24:49 +0200 (CEST)
Message-ID: <1522237479.23555412.1438194289391.JavaMail.zimbra@oxygem.tv>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pve-devel <pve-devel-KmHT29P9Uc/4CZzEM2C48g@public.gmane.org>
To: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <pve-devel-bounces-KmHT29P9Uc/4CZzEM2C48g@public.gmane.org>
List-Unsubscribe: <http://pve.proxmox.com/cgi-bin/mailman/options/pve-devel>,
 <mailto:pve-devel-request-KmHT29P9Uc/4CZzEM2C48g@public.gmane.org?subject=unsubscribe>
List-Archive: <http://pve.proxmox.com/pipermail/pve-devel/>
List-Post: <mailto:pve-devel-KmHT29P9Uc/4CZzEM2C48g@public.gmane.org>
List-Help: <mailto:pve-devel-request-KmHT29P9Uc/4CZzEM2C48g@public.gmane.org?subject=help>
List-Subscribe: <http://pve.proxmox.com/cgi-bin/mailman/listinfo/pve-devel>,
 <mailto:pve-devel-request-KmHT29P9Uc/4CZzEM2C48g@public.gmane.org?subject=subscribe>
Errors-To: pve-devel-bounces-KmHT29P9Uc/4CZzEM2C48g@public.gmane.org
Sender: "pve-devel" <pve-devel-bounces-KmHT29P9Uc/4CZzEM2C48g@public.gmane.org>
List-Id: netdev.vger.kernel.org

Hi, 

I'm currently testing vlan range on bridge filtering with kernel 4.1. 


If I defined too much vlans, or too big vlan range, 
I have a warning "message truncated", even if I'm using "-c" 


# bridge -c vlan 
Message truncated 
port vlan ids 
eth2 1 PVID Egress Untagged 

bond0 1 PVID Egress Untagged 
2-1850 

vmbr0 1 PVID Egress Untagged 
94 


or 
# bridge -c vlan 
Message truncated 
port vlan ids 
eth2 1 PVID Egress Untagged 
2-900 
bond0 1 PVID Egress Untagged 
2-900 

vmbr0 1 PVID Egress Untagged 
94 



Also, more important, this is also impact "ip", and truncate the output 

#ip link 

Message truncated 
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default 
link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00 
2: eth2: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 9000 qdisc pfifo_fast master vmbr1 state DOWN mode DEFAULT group default qlen 1000 
link/ether 00:15:17:80:29:e6 brd ff:ff:ff:ff:ff:ff 
3: eth3: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000 
link/ether 00:15:17:80:29:e7 brd ff:ff:ff:ff:ff:ff 
4: eth0: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc mq master bond0 state UP mode DEFAULT group default qlen 1000 
link/ether 00:1a:a0:3c:98:c5 brd ff:ff:ff:ff:ff:ff 
5: eth5: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9000 qdisc pfifo_fast master ovs-system state UP mode DEFAULT group default qlen 1000 
link/ether 68:05:ca:09:c3:7c brd ff:ff:ff:ff:ff:ff 
6: eth4: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9000 qdisc pfifo_fast master ovs-system state UP mode DEFAULT group default qlen 1000 
link/ether 68:05:ca:09:c3:7d brd ff:ff:ff:ff:ff:ff 
7: eth1: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc mq master bond0 state UP mode DEFAULT group default qlen 1000 
link/ether 00:1a:a0:3c:98:c5 brd ff:ff:ff:ff:ff:ff 
8: ovs-system@NONE: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default 
link/ether 7e:dd:5d:ea:ef:26 brd ff:ff:ff:ff:ff:ff 
9: vmbr10@NONE: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9000 qdisc noqueue state UNKNOWN mode DEFAULT group default 
link/ether 68:05:ca:09:c3:7d brd ff:ff:ff:ff:ff:ff 
10: bond1@NONE: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9000 qdisc noqueue state UNKNOWN mode DEFAULT group default 
link/ether 8a:c3:da:b0:9d:87 brd ff:ff:ff:ff:ff:ff 
11: bond0@NONE: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 qdisc noqueue master vmbr0 state UP mode DEFAULT group default 
link/ether 00:1a:a0:3c:98:c5 brd ff:ff:ff:ff:ff:ff 
12: vmbr0@NONE: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default 
link/ether 00:1a:a0:3c:98:c5 brd ff:ff:ff:ff:ff:ff 
13: vmbr0.94@vmbr0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default 
link/ether 00:1a:a0:3c:98:c5 brd ff:ff:ff:ff:ff:ff 

---->should have more interfaces here 


Is it a known bug ? 



Regards, 

Alexandre Derumier
