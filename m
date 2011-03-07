From: Weiping Pan <panweiping3@gmail.com>
Subject: Re: bonding can't change to another slave if you ifdown the active
 slave
Date: Mon, 07 Mar 2011 12:20:31 +0800
Message-ID: <4D745D0F.9090604@gmail.com>
References: <4D704B35.20700@gmail.com> <20110305025332.GR11864@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net,
	Linda Wang <lwang@redhat.com>
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:55687 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753934Ab1CGEYK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Mar 2011 23:24:10 -0500
Received: by vws12 with SMTP id 12so3400172vws.19
        for <netdev@vger.kernel.org>; Sun, 06 Mar 2011 20:24:09 -0800 (PST)
In-Reply-To: <20110305025332.GR11864@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/05/2011 10:53 AM, Andy Gospodarek wrote:
> On Fri, Mar 04, 2011 at 10:15:17AM +0800, Weiping Pan wrote:
>> Hi,
>>
>> I'm doing some Linux bonding driver test, and I find a problem in
>> balance-rr mode.
>> That's it can't change to another slave if you ifdown the active slave.
>> Any comments are warmly welcomed!
>>
>> regards
>> Weiping Pan
>>
>> My host is Fedora 14, and I install VirtualBox (4.0.2), and enable 4
>> nics for the guest system.
> Does this mean you are passing 4 NICs from your host to your guest
> (maybe via direct pci-device assignment to the guest) or are you
> creating 4 virtual devices on the host that are in a bridge group on the
> host?
>
> [...]
I use bridge mode in virtualbox.
[root@localhost ~]# VBoxManage showvminfo 
67b83c47-0ee2-46bc-b0ff-e0eb43edc1c2 |grep ^NIC
NIC 1:           MAC: 0800270481A8, Attachment: Bridged Interface 
'eth0', Cable connected: on, Trace: off (file: none), Type: 82540EM, 
Reported speed: 0 Mbps, Boot priority: 0
NIC 2:           MAC: 08002778F641, Attachment: Bridged Interface 
'eth0', Cable connected: on, Trace: off (file: none), Type: 82540EM, 
Reported speed: 0 Mbps, Boot priority: 0
NIC 3:           MAC: 080027C408BA, Attachment: Bridged Interface 
'eth0', Cable connected: on, Trace: off (file: none), Type: 82540EM, 
Reported speed: 0 Mbps, Boot priority: 0
NIC 4:           MAC: 080027DB339A, Attachment: Bridged Interface 
'eth0', Cable connected: on, Trace: off (file: none), Type: 82540EM, 
Reported speed: 0 Mbps, Boot priority: 0
NIC 5:           disabled
NIC 6:           disabled
NIC 7:           disabled
NIC 8:           disabled

>> [root@localhost ~]# ifconfig eth7 down
> This is not a great way to test link failure with bonding.  The best way
> is to actually pull the cable so the interface is truly down.
Ok.
But I think bonding should  work in such condition.
>> [root@localhost ~]# dmesg
>> [  304.496463] bonding: Ethernet Channel Bonding Driver: v3.6.0
>> (September 26, 2009)
>> [  304.496468] bonding: MII link monitoring set to 100 ms
>> [  353.527680] ADDRCONF(NETDEV_UP): bond0: link is not ready
>> [  355.321626] e1000: eth7 NIC Link is Up 1000 Mbps Full Duplex, Flow
>> Control: RX
>> [  355.322250] bonding: bond0: enslaving eth7 as an active interface
>> with an up link.
>> [  355.323503] ADDRCONF(NETDEV_CHANGE): bond0: link becomes ready
>> [  365.394052] bond0: no IPv6 routers present
>> [  510.913797] e1000: eth8 NIC Link is Up 1000 Mbps Full Duplex, Flow
>> Control: RX
>> [  510.917312] bonding: bond0: enslaving eth8 as an active interface
>> with an up link.
>> [  592.208534] bonding: bond0: link status definitely down for interface
>> eth7, disabling it
> I suspect I know, but what does /proc/net/bonding/bond0 look like?
[root@localhost ~]# cat /proc/net/bonding/bond0
Ethernet Channel Bonding Driver: v3.6.0 (September 26, 2009)

Bonding Mode: load balancing (round-robin)
MII Status: up
MII Polling Interval (ms): 100
Up Delay (ms): 0
Down Delay (ms): 0

Slave Interface: eth7
MII Status: down
Link Failure Count: 1
Permanent HW addr: 08:00:27:04:81:a8

Slave Interface: eth8
MII Status: up
Link Failure Count: 0
Permanent HW addr: 08:00:27:db:33:9a

> [...]
>> And meanwhile,
>> [root@localhost ~]# tcpdump -i bond0 -p arp
>> tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
>> listening on bond0, link-type EN10MB (Ethernet), capture size 65535 bytes
>> 02:46:56.983092 ARP, Request who-has 192.168.1.100 tell 192.168.1.5,
>> length 28
>> 02:46:57.984040 ARP, Request who-has 192.168.1.100 tell 192.168.1.5,
>> length 28
>> 02:46:58.988442 ARP, Request who-has 192.168.1.100 tell 192.168.1.5,
>> length 28
>> 02:47:00.987340 ARP, Request who-has 192.168.1.100 tell 192.168.1.5,
>> length 28
>> 02:47:01.988136 ARP, Request who-has 192.168.1.100 tell 192.168.1.5,
>> length 28
>> 02:47:02.990033 ARP, Request who-has 192.168.1.100 tell 192.168.1.5,
>> length 28
>> 02:47:04.985086 ARP, Request who-has 192.168.1.100 tell 192.168.1.5,
>> length 28
>> 02:47:05.992368 ARP, Request who-has 192.168.1.100 tell 192.168.1.5,
>> length 28
>> 02:47:06.996727 ARP, Request who-has 192.168.1.100 tell 192.168.1.5,
>> length 28
>> 02:47:17.231106 ARP, Request who-has dhcp-65-32.nay.redhat.com tell
>> dhcp-65-180.nay.redhat.com, length 46
>> ^C
>> 10 packets captured
>> 10 packets received by filter
>> 0 packets dropped by kernel
>>
>>
> What does a tcpdump on eth0 look like?  I'm curious if these arp
> requests make it there or if the responses are the frames being dropped
> (possibly by the connected bridge/switch).
on host,
[root@localhost ~]# tcpdump -i eth0 -p arp
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), capture size 65535 bytes
12:18:24.885306 ARP, Request who-has 192.168.1.100 tell 192.168.1.5, 
length 28
12:18:24.885320 ARP, Request who-has 192.168.1.100 tell 192.168.1.5, 
length 28
12:18:26.880019 ARP, Request who-has 192.168.1.100 tell 192.168.1.5, 
length 28
12:18:26.880030 ARP, Request who-has 192.168.1.100 tell 192.168.1.5, 
length 28
12:18:27.881584 ARP, Request who-has 192.168.1.100 tell 192.168.1.5, 
length 28
12:18:27.881593 ARP, Request who-has 192.168.1.100 tell 192.168.1.5, 
length 28
12:18:28.883657 ARP, Request who-has 192.168.1.100 tell 192.168.1.5, 
length 28
12:18:28.883671 ARP, Request who-has 192.168.1.100 tell 192.168.1.5, 
length 28
12:18:30.881699 ARP, Request who-has 192.168.1.100 tell 192.168.1.5, 
length 28
12:18:30.881709 ARP, Request who-has 192.168.1.100 tell 192.168.1.5, 
length 28
12:18:31.885003 ARP, Request who-has 192.168.1.100 tell 192.168.1.5, 
length 28
12:18:31.885012 ARP, Request who-has 192.168.1.100 tell 192.168.1.5, 
length 28
12:18:31.942278 ARP, Request who-has dhcp-65-14.nay.redhat.com tell 
corerouter.nay.redhat.com, length 46
12:18:32.721861 ARP, Request who-has dhcp-65-29.nay.redhat.com tell 
corerouter.nay.redhat.com, length 46
12:18:32.888740 ARP, Request who-has 192.168.1.100 tell 192.168.1.5, 
length 28
12:18:32.888748 ARP, Request who-has 192.168.1.100 tell 192.168.1.5, 
length 28

[root@localhost ~]# ip route show
192.168.1.0/24 dev eth0  proto kernel  scope link  src 192.168.1.100
10.66.64.0/23 dev eth0  proto kernel  scope link  src 10.66.65.228  
metric 1
default via 10.66.65.254 dev eth0  proto static
[root@localhost ~]# ip neigh show
192.168.1.5 dev eth0 lladdr 08:00:27:04:81:a8 STALE
10.66.65.254 dev eth0 lladdr 00:1d:45:20:d5:ff REACHABLE

regards
Weiping Pan

