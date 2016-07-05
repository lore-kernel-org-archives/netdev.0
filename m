From: domingo montoya <reach.domingomontoya@gmail.com>
Subject: Re: mlx5 SRIOV VLAN support
Date: Tue, 5 Jul 2016 14:53:21 +0530
Message-ID: <CAOYAsNmMRuqybSbLxFn4znC7SkzLx=0pppn2kb2rVX+57YAN9Q@mail.gmail.com>
References: <CAOYAsN=5VQM-QF+vnx=p1DtDV+912QO9kwDE-wszXmTJLc4uGA@mail.gmail.com>
 <CALzJLG8Y3N2PqbJuLTSbfWcxbWJuugZ62nJvz0_Tq7hFSN7axA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:35678 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751150AbcGEJYW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 05:24:22 -0400
Received: by mail-pa0-f66.google.com with SMTP id dx3so1317822pab.2
        for <netdev@vger.kernel.org>; Tue, 05 Jul 2016 02:23:23 -0700 (PDT)
In-Reply-To: <CALzJLG8Y3N2PqbJuLTSbfWcxbWJuugZ62nJvz0_Tq7hFSN7axA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks so much for the reply. Please find the logs.


Logs on the remote dedicated driver:
------------------------------------------------------

# ip link add link enp1s0f0 name enp1s0f0.100 type vlan id 100

# ifconfig enp1s0f0.100 10.2.2.25 up

# ip link show enp1s0f0.100
5: enp1s0f0.100@enp1s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500
qdisc noqueue state UP mode DEFAULT
    link/ether e4:1d:2d:c9:c8:9a brd ff:ff:ff:ff:ff:ff

# ethtool -k enp1s0f0.100
Features for enp1s0f0.100:
rx-checksumming: on [fixed]
tx-checksumming: on
        tx-checksum-ipv4: on
        tx-checksum-ip-generic: off
        tx-checksum-ipv6: on
        tx-checksum-fcoe-crc: off
        tx-checksum-sctp: off
scatter-gather: on
        tx-scatter-gather: on
        tx-scatter-gather-fraglist: off
tcp-segmentation-offload: on
        tx-tcp-segmentation: on
        tx-tcp-ecn-segmentation: off
        tx-tcp6-segmentation: on
udp-fragmentation-offload: off [fixed]
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off [fixed]
rx-vlan-offload: off [fixed]
tx-vlan-offload: off [fixed]
ntuple-filters: off [fixed]
receive-hashing: on [fixed]
highdma: on
rx-vlan-filter: off [fixed]
vlan-challenged: off [fixed]
tx-lockless: on [fixed]
netns-local: off [fixed]
tx-gso-robust: off [fixed]
tx-fcoe-segmentation: off
tx-gre-segmentation: off [fixed]
tx-ipip-segmentation: off [fixed]
tx-sit-segmentation: off [fixed]
tx-udp_tnl-segmentation: off [fixed]
tx-mpls-segmentation: off [fixed]
fcoe-mtu: off
tx-nocache-copy: off
loopback: off [fixed]
rx-fcs: off [fixed]
rx-all: off [fixed]
tx-vlan-stag-hw-insert: off [fixed]
rx-vlan-stag-hw-parse: off [fixed]
rx-vlan-stag-filter: off [fixed]
busy-poll: off [fixed]


# ip link show enp1s0f0
3: enp1s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state
UP mode DEFAULT qlen 1000
    link/ether e4:1d:2d:c9:c8:9a brd ff:ff:ff:ff:ff:ff

# ethtool -k enp1s0f0
Features for enp1s0f0:
rx-checksumming: on
tx-checksumming: on
        tx-checksum-ipv4: on
        tx-checksum-ip-generic: off [fixed]
        tx-checksum-ipv6: on
        tx-checksum-fcoe-crc: off [fixed]
        tx-checksum-sctp: off [fixed]
scatter-gather: on
        tx-scatter-gather: on
        tx-scatter-gather-fraglist: off [fixed]
tcp-segmentation-offload: on
        tx-tcp-segmentation: on
        tx-tcp-ecn-segmentation: off [fixed]
        tx-tcp6-segmentation: on
udp-fragmentation-offload: off [fixed]
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off
rx-vlan-offload: on
tx-vlan-offload: on
ntuple-filters: off
receive-hashing: on
highdma: on [fixed]
rx-vlan-filter: on
vlan-challenged: off [fixed]
tx-lockless: off [fixed]
netns-local: off [fixed]
tx-gso-robust: off [fixed]
tx-fcoe-segmentation: off [fixed]
tx-gre-segmentation: off [fixed]
tx-ipip-segmentation: off [fixed]
tx-sit-segmentation: off [fixed]
tx-udp_tnl-segmentation: on
tx-mpls-segmentation: off [fixed]
fcoe-mtu: off [fixed]
tx-nocache-copy: off
loopback: off [fixed]
rx-fcs: off [fixed]
rx-all: off [fixed]
tx-vlan-stag-hw-insert: off [fixed]
rx-vlan-stag-hw-parse: off [fixed]
rx-vlan-stag-filter: off [fixed]
busy-poll: off [fixed]


Logs on the remote dedicated driver before configuring VLAN:

# ip link show enp1s0f0
3: enp1s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state
UP mode DEFAULT qlen 1000
    link/ether e4:1d:2d:c9:c8:9a brd ff:ff:ff:ff:ff:ff

# ethtool -k enp1s0f0
Features for enp1s0f0:
rx-checksumming: on
tx-checksumming: on
        tx-checksum-ipv4: on
        tx-checksum-ip-generic: off [fixed]
        tx-checksum-ipv6: on
        tx-checksum-fcoe-crc: off [fixed]
        tx-checksum-sctp: off [fixed]
scatter-gather: on
        tx-scatter-gather: on
        tx-scatter-gather-fraglist: off [fixed]
tcp-segmentation-offload: on
        tx-tcp-segmentation: on
        tx-tcp-ecn-segmentation: off [fixed]
        tx-tcp6-segmentation: on
udp-fragmentation-offload: off [fixed]
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off
rx-vlan-offload: on
tx-vlan-offload: on
ntuple-filters: off
receive-hashing: on
highdma: on [fixed]
rx-vlan-filter: on
vlan-challenged: off [fixed]
tx-lockless: off [fixed]
netns-local: off [fixed]
tx-gso-robust: off [fixed]
tx-fcoe-segmentation: off [fixed]
tx-gre-segmentation: off [fixed]
tx-ipip-segmentation: off [fixed]
tx-sit-segmentation: off [fixed]
tx-udp_tnl-segmentation: on
tx-mpls-segmentation: off [fixed]
fcoe-mtu: off [fixed]
tx-nocache-copy: off
loopback: off [fixed]
rx-fcs: off [fixed]
rx-all: off [fixed]
tx-vlan-stag-hw-insert: off [fixed]
rx-vlan-stag-hw-parse: off [fixed]
rx-vlan-stag-filter: off [fixed]
busy-poll: off [fixed]


Logs on the VF:
---------------------------


# ip link add link eth0 name eth0.100 type vlan id 100

# ifconfig eth0.100 10.2.2.20 up

# ip link show eth0.100
5: eth0.100@eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc
noqueue state UP mode DEFAULT
    link/ether fa:14:86:e6:ac:00 brd ff:ff:ff:ff:ff:ff

# ethtool -k eth0.100
Features for eth0.100:
rx-checksumming: on [fixed]
tx-checksumming: on
        tx-checksum-ipv4: on
        tx-checksum-ip-generic: off
        tx-checksum-ipv6: on
        tx-checksum-fcoe-crc: off
        tx-checksum-sctp: off
scatter-gather: on
        tx-scatter-gather: on
        tx-scatter-gather-fraglist: off
tcp-segmentation-offload: on
        tx-tcp-segmentation: on
        tx-tcp-ecn-segmentation: off
        tx-tcp6-segmentation: on
udp-fragmentation-offload: off [fixed]
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off [fixed]
rx-vlan-offload: off [fixed]
tx-vlan-offload: off [fixed]
ntuple-filters: off [fixed]
receive-hashing: on [fixed]
highdma: on
rx-vlan-filter: off [fixed]
vlan-challenged: off [fixed]
tx-lockless: on [fixed]
netns-local: off [fixed]
tx-gso-robust: off [fixed]
tx-fcoe-segmentation: off
tx-gre-segmentation: off [fixed]
tx-ipip-segmentation: off [fixed]
tx-sit-segmentation: off [fixed]
tx-udp_tnl-segmentation: off [fixed]
tx-mpls-segmentation: off [fixed]
fcoe-mtu: off
tx-nocache-copy: off
loopback: off [fixed]
rx-fcs: off [fixed]
rx-all: off [fixed]
tx-vlan-stag-hw-insert: off [fixed]
rx-vlan-stag-hw-parse: off [fixed]
rx-vlan-stag-filter: off [fixed]
busy-poll: off [fixed]

# ip link show eth0
4: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP
mode DEFAULT qlen 1000
    link/ether fa:14:86:e6:ac:00 brd ff:ff:ff:ff:ff:ff


# ethtool -k eth0
Features for eth0:
rx-checksumming: on
tx-checksumming: on
        tx-checksum-ipv4: on
        tx-checksum-ip-generic: off [fixed]
        tx-checksum-ipv6: on
        tx-checksum-fcoe-crc: off [fixed]
        tx-checksum-sctp: off [fixed]
scatter-gather: on
        tx-scatter-gather: on
        tx-scatter-gather-fraglist: off [fixed]
tcp-segmentation-offload: on
        tx-tcp-segmentation: on
        tx-tcp-ecn-segmentation: off [fixed]
        tx-tcp6-segmentation: on
udp-fragmentation-offload: off [fixed]
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off
rx-vlan-offload: on
tx-vlan-offload: on
ntuple-filters: off
receive-hashing: on
highdma: on [fixed]
rx-vlan-filter: on
vlan-challenged: off [fixed]
tx-lockless: off [fixed]
netns-local: off [fixed]
tx-gso-robust: off [fixed]
tx-fcoe-segmentation: off [fixed]
tx-gre-segmentation: off [fixed]
tx-ipip-segmentation: off [fixed]
tx-sit-segmentation: off [fixed]
tx-udp_tnl-segmentation: off [fixed]
tx-mpls-segmentation: off [fixed]
fcoe-mtu: off [fixed]
tx-nocache-copy: off
loopback: off [fixed]
rx-fcs: off [fixed]
rx-all: off [fixed]
tx-vlan-stag-hw-insert: off [fixed]
rx-vlan-stag-hw-parse: off [fixed]
rx-vlan-stag-filter: off [fixed]
busy-poll: off [fixed]

Logs on the VF before configuring VLAN:
==================================

# ip link show eth0
4: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP
mode DEFAULT qlen 1000
    link/ether fa:14:86:e6:ac:00 brd ff:ff:ff:ff:ff:ff


# ethtool -k eth0
Features for eth0:
rx-checksumming: on
tx-checksumming: on
        tx-checksum-ipv4: on
        tx-checksum-ip-generic: off [fixed]
        tx-checksum-ipv6: on
        tx-checksum-fcoe-crc: off [fixed]
        tx-checksum-sctp: off [fixed]
scatter-gather: on
        tx-scatter-gather: on
        tx-scatter-gather-fraglist: off [fixed]
tcp-segmentation-offload: on
        tx-tcp-segmentation: on
        tx-tcp-ecn-segmentation: off [fixed]
        tx-tcp6-segmentation: on
udp-fragmentation-offload: off [fixed]
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off
rx-vlan-offload: on
tx-vlan-offload: on
ntuple-filters: off
receive-hashing: on
highdma: on [fixed]
rx-vlan-filter: on
vlan-challenged: off [fixed]
tx-lockless: off [fixed]
netns-local: off [fixed]
tx-gso-robust: off [fixed]
tx-fcoe-segmentation: off [fixed]
tx-gre-segmentation: off [fixed]
tx-ipip-segmentation: off [fixed]
tx-sit-segmentation: off [fixed]
tx-udp_tnl-segmentation: off [fixed]
tx-mpls-segmentation: off [fixed]
fcoe-mtu: off [fixed]
tx-nocache-copy: off
loopback: off [fixed]
rx-fcs: off [fixed]
rx-all: off [fixed]
tx-vlan-stag-hw-insert: off [fixed]
rx-vlan-stag-hw-parse: off [fixed]
rx-vlan-stag-filter: off [fixed]
busy-poll: off [fixed]





On Tue, Jul 5, 2016 at 1:41 PM, Saeed Mahameed
<saeedm@dev.mellanox.co.il> wrote:
> On Tue, Jul 5, 2016 at 10:37 AM, domingo montoya
> <reach.domingomontoya@gmail.com> wrote:
>> Hi,
>>
>> Is VLAN supported in SRIOV mode for mlx5?
>>
>
> For VGT mode vlan is supported by default same as bare-metal.
> For VST you need to use ip tool to configure VST vlan:  ip link set
> eth<X> vf 1 vlan 2 qos 2
>
> note: VGT mode will not work on VF if VST is configured on that VF.

Can you please tell me how can I check if VST mode is enabled on the
VF from the VF driver.



>
>>
>> Can anyone please help me to:
>>
>> Enable VLAN guest tagging in mlx5 PF driver?
>>
>> Do I need to add any E-switch rules to do the same?
>>
>
> No,
> Nothing is required for VGT mode, just create the vlan on guest VF
> machine and work with it!
> E-Swtich is automatically/dynamically configured.


Is it something like when we create vlan on the guest VF, the VF
driver sends commands to the adapter fw and the adapter fw sends any
notification to the PF driver to configure Eswitch?


>
>>
>> My requirement is something like this:
>>
>>
>> mlx5 VF driver<--------------->mlx5 PF
>> driver<------------------------->Network<-----------> mlx5 dedicated
>> driver(non-sriov)
>>
>>
>>
>> I would like to be able to send ICMP traffic between mlx5 VF driver
>> and mlx5 dedicated driver.
>>
>> My understanding is I should be able to do without adding any rules in
>> the E-switch on the PF driver as by default all traffic is allowed.
>>
>> Is this correct?
>>
>
> correct.
>
>>
>>
>> I tried but as this didn't work. I added ingress rules to allow VLAN
>> traffic and also egress rules to the E-switch ACL tables.
>>
>
> How did you do this ? changed the code ? by default (no VST/no spoof
> check) ACL tables should not be opened.


Yes. I changed the code. Okay. Now I understand that ACL tables are
only for VST or spoofcheck. Thanks!

>
>> But still i cannot see any traffic between mlx5 VF driver and mlx5
>> dedicated driver.
>>
>> I can see that the packets reach the CX4 adapter (mlx5 VF/mlx5 PF) but
>> they don't go out on the network.
>>
>> i tried configuring vlan using ip link add dev enp1s0f0 name
>> enp1s0f0.100 type vlan id 100 on both the mlx5 vf driver and mlx5
>> dedicated driver.
>>
>>
>
> Strange, should work. Please make sure VST mode is off on the VF.
> can you share some logs with us:
> on PF/VF and remote dedicated driver:
>
> ip link show <interface>
> ethtool -k <interface>


Sure. Wanted to check how to turn off the VST mode on the VF or make
sure it is off.  I have pasted the logs with this mail(at the
beginning).
I had one more doubt. If we need to disable VST mode on the VF from
the PF driver, using for e.g

ip link set dev eth0 vf 2 4095,

will this command eventually call .ndo_set_vf_vlan and setup the
Eswitch ACL Ingress, Egress rules?


>
> Thanks,
> Saeed.


Thanks so much for your help!!
Best Regards,
Domingo
