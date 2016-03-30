From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: am335x: no multicast reception over VLAN
Date: Wed, 30 Mar 2016 22:22:01 +0530
Message-ID: <56FC0431.5000106@ti.com>
References: <CAGm1_ktOqB4QBMy2G4XeHTkaP+WvG8GOc8maVv3dDoxM+-F+ZA@mail.gmail.com>
 <56F9FDD0.8030504@ti.com>
 <CAGm1_ksxRPCAqx4n5gbsARSYeF116BT7r8cC6=1QYnEsYRxpVw@mail.gmail.com>
 <56FA616C.9080502@ti.com>
 <CAGm1_ksvEdk-mF-hW4o5+bri6J6sMgnQQVD3j-e7xm6PsP8k0A@mail.gmail.com>
 <56FA78AA.4030402@ti.com> <56FB6543.9060904@ti.com>
 <CAGm1_kvXA4egrK8-oCedYjvPm7BhJdy_w-5ON24snYdKiN3K7g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Grygorii Strashko <grygorii.strashko@ti.com>,
	netdev <netdev@vger.kernel.org>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
	<drivshin@allworx.com>, <ml@markusgrimm.de>
To: Yegor Yefremov <yegorslists@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:53819 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932265AbcC3QwM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Mar 2016 12:52:12 -0400
In-Reply-To: <CAGm1_kvXA4egrK8-oCedYjvPm7BhJdy_w-5ON24snYdKiN3K7g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 30 March 2016 02:05 PM, Yegor Yefremov wrote:
> On Wed, Mar 30, 2016 at 7:33 AM, Mugunthan V N <mugunthanvnm@ti.com> wrote:
>> On Tuesday 29 March 2016 06:14 PM, Grygorii Strashko wrote:
>>> On 03/29/2016 03:35 PM, Yegor Yefremov wrote:
>>>> On Tue, Mar 29, 2016 at 1:05 PM, Grygorii Strashko
>>>> <grygorii.strashko@ti.com> wrote:
>>>>> On 03/29/2016 08:21 AM, Yegor Yefremov wrote:
>>>>>> Hi Mugunthan,
>>>>>>
>>>>>> On Tue, Mar 29, 2016 at 6:00 AM, Mugunthan V N <mugunthanvnm@ti.com> wrote:
>>>>>>> Hi Yegor
>>>>>>>
>>>>>>> On Wednesday 16 March 2016 08:35 PM, Yegor Yefremov wrote:
>>>>>>>> I have an am335x based board using CPSW in Dual EMAC mode. Without
>>>>>>>> VLAN IDs I can receive and send multicast packets [1]. When I create
>>>>>>>> VLAN ID:
>>>>>>>>
>>>>>>>> ip link add link eth1 name eth1.100 type vlan id 100
>>>>>>>> ip addr add 192.168.100.2/24 brd 192.168.100.255 dev eth1.100
>>>>>>>> route add -net 224.0.0.0 netmask 224.0.0.0 eth1.100
>>>>>>>>
>>>>>>>> I can successfully send multicast packets, but not receive them. On
>>>>>>>> the other side of the Ethernet cable I've used Pandaboard. Pandaboard
>>>>>>>> could both receive and send multicast packets via VLAN.
>>>>>>>
>>>>>>> Are you trying multicast tx/rx on eth1 or eth1.100?
>>>>>>
>>>>>> I'm trying multicast tx/rx on eth1.100.
>>>>>>
>>>>>> eth1 has no problems.
>>>>>>
>>>>>
>>>>> it'd be nice if will be able to post here output fom commands:
>>>>> # switch-config -d [git://git.ti.com/switch-config/switch-config.git v4.1]
>>>>> # ifconfig -a
>>>>> # tcpdump -e -f -Q in -i eth0
>>>>> # tcpdump -e -f -Q in -i eth0.100
>>>>
>>>> Which kernel/branch do you want me to test?
>>>>
>>>> git://git.ti.com/ti-linux-kernel/ti-linux-kernel.git and ti-rt-linux-4.1.y?
>>>>
>>>> So far I was using vanilla kernel.
>>>
>>> Your branch (but better 4.5 kernels (or 4.4)).
>>> Just when you've done with configuration run cmds 1&2,
>>> and when you run your use-case - run cmds 2&3 on receiver side (grap ~5-10 packets).
>>> then stop test and run cmd 1 again.
>>>
>>> After all could you provide your console output here, pls.
>>>
>>>
>>
>> To use command 1, you need TI kernel [1] as it won't build with vanilla
>> kernel.
>>
>> [1]: git://git.ti.com/ti-linux-kernel/ti-linux-kernel.git ti-linux-4.1.y
> 
> # uname -a
> Linux buildroot 4.1.18 #1 SMP Wed Mar 30 09:48:37 CEST 2016 armv7l GNU/Linux
> 
> # switch-config -d
> cpsw hw version 1.12 (0)
> 0   : type: vlan , vid = 1, untag_force = 0x3, reg_mcast = 0x3,
> unreg_mcast = 0x1, member_list = 0x3
> 
> 1   : type: mcast, vid = 1, addr = ff:ff:ff:ff:ff:ff, mcast_state = f,
> no super, port_mask = 0x3
> 2   : type: ucast, vid = 1, addr = 74:6a:8f:00:16:12, ucast_type =
> persistant, port_num = 0x0, Secure
> 3   : type: vlan , vid = 0, untag_force = 0x7, reg_mcast = 0x0,
> unreg_mcast = 0x1, member_list = 0x7
> 4   : type: mcast, vid = 1, addr = 01:00:5e:00:00:01, mcast_state = f,
> no super, port_mask = 0x3
> 5   : type: vlan , vid = 2, untag_force = 0x5, reg_mcast = 0x5,
> unreg_mcast = 0x1, member_list = 0x5
> 6   : type: mcast, vid = 2, addr = ff:ff:ff:ff:ff:ff, mcast_state = f,
> no super, port_mask = 0x5
> 7   : type: ucast, vid = 2, addr = 74:6a:8f:00:16:13, ucast_type =
> persistant, port_num = 0x0, Secure
> 8   : type: mcast, vid = 2, addr = 01:00:5e:00:00:01, mcast_state = f,
> no super, port_mask = 0x5
> 9   : type: vlan , vid = 100, untag_force = 0x0, reg_mcast = 0x5,
> unreg_mcast = 0x1, member_list = 0x5
> 10  : type: ucast, vid = 100, addr = 74:6a:8f:00:16:13, ucast_type =
> persistant, port_num = 0x0
> 11  : type: mcast, vid = 100, addr = ff:ff:ff:ff:ff:ff, mcast_state =
> f, no super, port_mask = 0x5
> 12  : type: mcast, vid = 2, addr = 01:80:c2:00:00:21, mcast_state = f,
> no super, port_mask = 0x5
> 13  : type: mcast, vid = 2, addr = 01:00:5e:03:1d:47, mcast_state = f,
> no super, port_mask = 0x5

I don't see multicast entry added to ALE table for 01:00:5e:03:1d:47,
can you run the receive command in background/another terminal and get
the dump when receiving on eth1 and eth1.100 as well and don't enable
tcpdump as it will put the switch in promiscuous mode.

> 
> # ifconfig -a
> can0      Link encap:UNSPEC  HWaddr
> 00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00
>           NOARP  MTU:16  Metric:1
>           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:10
>           RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
>           Interrupt:165
> 
> eth0      Link encap:Ethernet  HWaddr 74:6A:8F:00:16:12
>           inet addr:192.168.254.254  Bcast:0.0.0.0  Mask:255.255.255.0
>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:1000
>           RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
>           Interrupt:175
> 
> eth1      Link encap:Ethernet  HWaddr 74:6A:8F:00:16:13
>           inet addr:192.168.1.233  Bcast:0.0.0.0  Mask:255.255.255.0
>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>           RX packets:245 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:123 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:1000
>           RX bytes:40995 (40.0 KiB)  TX bytes:14086 (13.7 KiB)
> 
> eth1.100  Link encap:Ethernet  HWaddr 74:6A:8F:00:16:13
>           inet addr:192.168.100.2  Bcast:192.168.100.255  Mask:255.255.255.0
>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>           RX packets:65 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:51 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:0
>           RX bytes:8369 (8.1 KiB)  TX bytes:6340 (6.1 KiB)
> 
> lo        Link encap:Local Loopback
>           inet addr:127.0.0.1  Mask:255.0.0.0
>           UP LOOPBACK RUNNING  MTU:65536  Metric:1
>           RX packets:4 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:4 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:0
>           RX bytes:344 (344.0 B)  TX bytes:344 (344.0 B)
> 
> # tcpdump -e -f -Q in -i eth1
> tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
> listening on eth1, link-type EN10MB (Ethernet), capture size 262144 bytes
> 00:47:40.240731 06:15:4d:85:61:1e (oui Unknown) > 01:00:5e:03:1d:47
> (oui Unknown), ethertype 802.1Q (0x8100), length 65: vlan 100, p 0,
> ethertype IPv4, 192.168.100.1.59870 > 224.3.29.71.10000: UDP, length
> 19
> 00:47:45.259285 06:15:4d:85:61:1e (oui Unknown) > 74:6a:8f:00:16:13
> (oui Unknown), ethertype 802.1Q (0x8100), length 60: vlan 100, p 0,
> ethertype ARP, Reply 192.168.100.1 is-at 06:15:4d:85:61:1e (oui
> Unknown), length 42
> 
> # tcpdump -e -f -Q in -i eth1.100
> tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
> listening on eth1.100, link-type EN10MB (Ethernet), capture size 262144 bytes
> 00:48:52.477500 06:15:4d:85:61:1e (oui Unknown) > 01:00:5e:03:1d:47
> (oui Unknown), ethertype IPv4 (0x0800), length 61: 192.168.100.1.54382
>> 224.3.29.71.10000: UDP, length 19
> 00:48:57.486437 06:15:4d:85:61:1e (oui Unknown) > 74:6a:8f:00:16:13
> (oui Unknown), ethertype ARP (0x0806), length 56: Reply 192.168.100.1
> is-at 06:15:4d:85:61:1e (oui Unknown), length 42

You had received these packets as tcpdump will enable promiscuous mode
so that you receive all the packets from the wire.

> 
> What does "no super" mean and where can I see the "--fwd-state <value
> 0-3>" value/description?

Multicast supervisory packets are designated by the super bit in the
table entry. Supervisory packets are not dropped due to rate limiting,
OUI, or VLAN processing.

You can get the documentation in TRM under title "Multicast Forward
State (MCAST_FWD_STATE)" for forward state description.

Regards
Mugunthan V N
