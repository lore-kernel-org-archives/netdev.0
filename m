From: Kevin Stewart <kevins@callplus.co.nz>
Subject: One IP on 2 nics
Date: Fri, 10 Dec 2004 13:59:41 +1300
Message-ID: <41B8F4FD.6080407@callplus.co.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

What I am after is the ability to keep one IP and MAC address when I 
remove my laptop from my docking station (I have a 802.11b AP on the 
same segment as my other nic)

how do I create a vertual interface and configure my eth0(10/100) and 
eth1(802.11b)
so I can route traffic out the correct interface depending on what is up

this is the closest I have come
but my laptop becoming part of spanning tree sounds .... bad
bridging and not being part of spanning tree .... worse

iface br0 inet static
        address 192.168.18.64
        netmask 255.255.240.0
        network 192.168.16.0
        broadcast 192.168.31.255
        gateway 192.168.18.1
        bridge_ports eth0 eth1
        pre-up ifconfig eth0 0.0.0.0 up
        pre-up ifconfig eth1 0.0.0.0 up
        pre-up brctl addbr br0
        pre-up brctl addif br0 eth0
        pre-up brctl addif br0 eth1
        pre-up brctl stp br0 on
        post-down ifconfig eth0 0.0.0.0 down
        post-down ifconfig eth1 0.0.0.0 down
        post-down brctl delif br0 eth0
        post-down brctl delif br0 eth1
        post-down brctl delbr br0

my thoughts where a dummy interface and 2 routes to 192.168.16.0 with 
diffrent metrics out the 2 interfaces and a default route
but I am unable to get it working

-- 
Kevin Stewart

Network Engineer
DDI ++ 64 9 919 6120
Mobile ++ 64 21 885 505
Email kevins@callplus.co.nz


-----------------------------------------------------------------------------------------------
This message and any attachments contain privileged and confidential information. 
If you are not the intended recipient of this message, you are hereby notified that any use, dissemination, distribution or reproduction of this message is prohibited.  If you have received this message in error please notify the sender immediately via email and then destroy this message and any attachments.
