From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: bnx2: can't disable rx-vlan-offload?
Date: Wed, 15 Oct 2014 16:37:25 +0200
Message-ID: <543E86A5.8010406@gmail.com>
References: <DUB123-W35654C3B747AEBC067DAF8EDAD0@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Lukas Tribus <luky-37@hotmail.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	"Dept-HSGLinuxNICDev@qlogic.com" <dept-hsglinuxnicdev@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f182.google.com ([209.85.216.182]:40091 "EHLO
	mail-qc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751262AbaJOOha (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2014 10:37:30 -0400
Received: by mail-qc0-f182.google.com with SMTP id i17so1013142qcy.41
        for <netdev@vger.kernel.org>; Wed, 15 Oct 2014 07:37:30 -0700 (PDT)
In-Reply-To: <DUB123-W35654C3B747AEBC067DAF8EDAD0@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/14/2014 06:05 PM, Lukas Tribus wrote:
> Hi!
> 
> 
> For a passive, libpcap based sniffer I'm trying to disable rx vlan
> offload on a bnx2 card (vlan capture filter in libpcap doesn't work
> correctly), but I'm not able to:
> 
> disabling rxvlan fails:
> 
> root@sniffer:~# ethtool -K eth1 rxvlan off
> Could not change any device features
> root@sniffer:~#
> root@sniffer:~# ethtool -k eth1
> Features for eth1:
> rx-checksumming: on
> tx-checksumming: on
>         tx-checksum-ipv4: on
>         tx-checksum-ip-generic: off [fixed]
>         tx-checksum-ipv6: on
>         tx-checksum-fcoe-crc: off [fixed]
>         tx-checksum-sctp: off [fixed]
> scatter-gather: on
>         tx-scatter-gather: on
>         tx-scatter-gather-fraglist: off [fixed]
> tcp-segmentation-offload: on
>         tx-tcp-segmentation: on
>         tx-tcp-ecn-segmentation: on
>         tx-tcp6-segmentation: on
> udp-fragmentation-offload: off [fixed]
> generic-segmentation-offload: on
> generic-receive-offload: on
> large-receive-offload: off [fixed]
> rx-vlan-offload: on [requested off]
> tx-vlan-offload: on
> ntuple-filters: off [fixed]
> receive-hashing: on
> highdma: on [fixed]
> rx-vlan-filter: off [fixed]
> vlan-challenged: off [fixed]
> tx-lockless: off [fixed]
> netns-local: off [fixed]
> tx-gso-robust: off [fixed]
> tx-fcoe-segmentation: off [fixed]
> tx-gre-segmentation: off [fixed]
> tx-ipip-segmentation: off [fixed]
> tx-sit-segmentation: off [fixed]
> tx-udp_tnl-segmentation: off [fixed]
> tx-mpls-segmentation: off [fixed]
> fcoe-mtu: off [fixed]
> tx-nocache-copy: on
> loopback: off [fixed]
> rx-fcs: off [fixed]
> rx-all: off [fixed]
> tx-vlan-stag-hw-insert: off [fixed]
> rx-vlan-stag-hw-parse: off [fixed]
> rx-vlan-stag-filter: off [fixed]
> l2-fwd-offload: off [fixed]
> root@sniffer:~#
> root@sniffer:~# ethtool -i eth1
> driver: bnx2
> version: 2.2.4
> firmware-version: 5.0.9 bc 5.0.6 NCSI 2.0.3
> bus-info: 0000:01:00.1
> supports-statistics: yes
> supports-test: yes
> supports-eeprom-access: yes
> supports-register-dump: yes
> supports-priv-flags: no
> root@sniffer:~#
> 
> dmesg bnx2 lines:
> [    6.974972] bnx2: Broadcom NetXtreme II Gigabit Ethernet Driver bnx2 v2.2.4 (Aug 05, 2013)
> [    6.975681] bnx2 0000:01:00.0 eth0: Broadcom NetXtreme II BCM5716 1000Base-T (C0) PCI Express found at mem da000000, IRQ 36, node addr 00:26:b9:51:ba:59
> [    6.976631] bnx2 0000:01:00.1 eth1: Broadcom NetXtreme II BCM5716 1000Base-T (C0) PCI Express found at mem dc000000, IRQ 48, node addr 00:26:b9:51:ba:5a
> 
> 
> I'm using Ubuntus 3.13 kernel and ethtool version 3.13, but I previously
> tried ethtool 3.1 on both ubuntu 3.8 kernel and a vanilla 3.14.21
> kernel as well.
> 
> 
> Any ideas or workarounds that may help disabling rx vlan acceleration?

Try bringing the interface down first.  BNX2 is a bit strange in how it handles
vlan feature changes.

-vlad

> 
> 
> 
> 
> Thanks!
> 
> Lukas
> 
> 
>  		 	   		  --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
