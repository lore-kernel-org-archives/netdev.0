From: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
Subject: RE: Performance problem with bond interface
Date: Mon, 21 Apr 2014 11:32:28 -0700 (PDT)
Message-ID: <a4c977be-1a10-4c47-9b39-c3905161746d@default>
References: <5e9e32bb-b60e-44d1-82be-28c4d6ec82d5@default>
 <1398095238.19600.36.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Rama Nichanamatlu <rama.nichanamatlu@oracle.com>,
	Sergey Linetskiy <sergey.linetskiy@oracle.com>,
	Vadim Makhervaks <vadim.makhervaks@oracle.com>,
	Guangyu Sun <guangyu.sun@oracle.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	=?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:26300 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753374AbaDUScn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2014 14:32:43 -0400
In-Reply-To: <1398095238.19600.36.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,
> 
> Do these NIC really not support TX checksum ?
> 

In IPoIB connected (IB RC) mode the TX checksum is not supported.
In datagram mode it is supported.

> You did not provide kernel version you use.

So far we have tested against 2.6.39 and 3.8.13.
 
> 
> Please also provide : (using a recent ethtool to get extended offload
> info)
> 
> ethtool -k bond0 # or the bonding device name
> 
# ethtool -k bond0 | more
Features for bond0:
rx-checksumming: off [fixed]
tx-checksumming: on
        tx-checksum-ipv4: off [fixed]
        tx-checksum-ip-generic: on
        tx-checksum-ipv6: off [fixed]
        tx-checksum-fcoe-crc: off [fixed]
        tx-checksum-sctp: off [fixed]
scatter-gather: off
        tx-scatter-gather: off [requested on]
        tx-scatter-gather-fraglist: off [requested on]
tcp-segmentation-offload: off
        tx-tcp-segmentation: off [requested on]
        tx-tcp-ecn-segmentation: off [requested on]
        tx-tcp6-segmentation: off [requested on]
udp-fragmentation-offload: off [fixed]
generic-segmentation-offload: off [requested on]
generic-receive-offload: on
large-receive-offload: on
rx-vlan-offload: on
tx-vlan-offload: on
ntuple-filters: off [fixed]
receive-hashing: off [fixed]
highdma: on
rx-vlan-filter: on
vlan-challenged: on [fixed]
tx-lockless: on [fixed]
netns-local: off [fixed]
tx-gso-robust: off [fixed]
tx-fcoe-segmentation: off [fixed]
fcoe-mtu: off [fixed]
tx-nocache-copy: on
loopback: on [fixed]
rx-fcs: off [fixed]
rx-all: off [fixed]

> ethtool -k eth1  # or the slave name
> 
# ethtool -k ib0 | more
Features for ib0:
rx-checksumming: on
tx-checksumming: off
        tx-checksum-ipv4: off [requested on]
        tx-checksum-ip-generic: off [fixed]
        tx-checksum-ipv6: off [fixed]
        tx-checksum-fcoe-crc: off [fixed]
        tx-checksum-sctp: off [fixed]
scatter-gather: off
        tx-scatter-gather: off [requested on]
        tx-scatter-gather-fraglist: off [fixed]
tcp-segmentation-offload: off
        tx-tcp-segmentation: off [requested on]
        tx-tcp-ecn-segmentation: off [fixed]
        tx-tcp6-segmentation: off [fixed]
udp-fragmentation-offload: off [fixed]
generic-segmentation-offload: off [requested on]
generic-receive-offload: on
large-receive-offload: off [fixed]
rx-vlan-offload: off [fixed]
tx-vlan-offload: off [fixed]
ntuple-filters: off [fixed]
receive-hashing: off [fixed]
highdma: on [fixed]
rx-vlan-filter: off [fixed]
vlan-challenged: on [fixed]
tx-lockless: off [fixed]
netns-local: off [fixed]
tx-gso-robust: off [fixed]
tx-fcoe-segmentation: off [fixed]
fcoe-mtu: off [fixed]
tx-nocache-copy: on
loopback: off [fixed]
rx-fcs: off [fixed]
rx-all: off [fixed]

> ethtool -i eth1
> 
# ethtool -i ib0
driver: ipoib
version:
firmware-version:
bus-info:
supports-statistics: yes
supports-test: no
supports-eeprom-access: no
supports-register-dump: no
supports-priv-flags: no

2nd slave:
-----------
# ethtool -k ib1 | more
Features for ib1:
rx-checksumming: on
tx-checksumming: off
        tx-checksum-ipv4: off [requested on]
        tx-checksum-ip-generic: off [fixed]
        tx-checksum-ipv6: off [fixed]
        tx-checksum-fcoe-crc: off [fixed]
        tx-checksum-sctp: off [fixed]
scatter-gather: off
        tx-scatter-gather: off [requested on]
        tx-scatter-gather-fraglist: off [fixed]
tcp-segmentation-offload: off
        tx-tcp-segmentation: off [requested on]
        tx-tcp-ecn-segmentation: off [fixed]
        tx-tcp6-segmentation: off [fixed]
udp-fragmentation-offload: off [fixed]
generic-segmentation-offload: off [requested on]
generic-receive-offload: on
large-receive-offload: off [fixed]
rx-vlan-offload: off [fixed]
tx-vlan-offload: off [fixed]
ntuple-filters: off [fixed]
receive-hashing: off [fixed]
highdma: on [fixed]
rx-vlan-filter: off [fixed]
vlan-challenged: on [fixed]
tx-lockless: off [fixed]
netns-local: off [fixed]
tx-gso-robust: off [fixed]
tx-fcoe-segmentation: off [fixed]
fcoe-mtu: off [fixed]
tx-nocache-copy: on
loopback: off [fixed]
rx-fcs: off [fixed]
rx-all: off [fixed]

# ethtool -i ib1
driver: ipoib
version:
firmware-version:
bus-info:
supports-statistics: yes
supports-test: no
supports-eeprom-access: no
supports-register-dump: no
supports-priv-flags: no

> Thanks !
> 
> 

Thanks for looking at it.

Venkat
