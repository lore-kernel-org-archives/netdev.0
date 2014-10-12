From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: vxlan gro problem ?
Date: Sun, 12 Oct 2014 21:50:59 +0200
Message-ID: <543ADBA3.5030305@mellanox.com>
References: <5434FA02.8070608@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<lichunhe@huawei.com>, <wangfakai@huawei.com>
To: yinpeijun <yinpeijun@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5434FA02.8070608@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/8/2014 10:46 AM, yinpeijun wrote:
> Hi all,
>          recently Linux 3.14 has been released and I find the networking has added udp gro and vxlan gro funtion, then I use the redhat 7.0(there is also add this funtion)
> to test, I use kernel vxlan module and  create a vxlan device then attach the device to  ovs  bridge , the configure as follow:
>         root@25:~$ ip link
>          15: vxlan0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue master ovs-system state UNKNOWN mode DEFAULT
>              link/ether be:e1:ae:3d:8b:f2 brd ff:ff:ff:ff:ff:ff
>          16: vnet0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1400 qdisc mq master ovs-system state UNKNOWN mode DEFAULT qlen 5000
>         
>         root@25:~$ ovs-vsctl show
>          aa1294f3-9952-4393-b2b5-54e9a6eb76ee
>          Bridge ovs-vx
>              Port ovs-vx
>                  Interface ovs-vx
>                      type: internal
>              Port "vnet0"
>                  Interface "vnet0"
>              Port "vxlan0"
>                  Interface "vxlan0"
>          ovs_version: "2.0.2"
>
> vnet0 is a vm backend device,  and the end is the same configuration. then I use netperf to test throughput  in vm (netperf -H **** -t TCP_STREAM -l 10 -- -m 1460),
> the result is 3-4 Gbit/sec, the  improvement  is not obvious,   and I also confused there is no aggregation  packets (length > mtu) in the end vm.   so I want to know what
> wrong ?   or how to test the function ?
>

As things are set in 3.14 and AFAIK also in RHEL 7.0, for GRO/VXLAN to 
come into play you need to run over a NIC which supports RX checksum 
offload too, is this the case?

Also, the configuration you run with isn't the typical play of VXLAN 
with OVS... I didn't try it out and this week being out to LPC.

Did you try the usual track of running OVS VXLAN port?e.g as explained 
in the Example section of [1]

Or.

[1] http://community.mellanox.com/docs/DOC-1446

Or.
