From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Regression: TCP connections fail over wireless: bad cksum?
Date: Thu, 04 Sep 2014 16:28:07 -0700
Message-ID: <1409873287.26422.127.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5408C788.4050401@tedp.id.au>
	 <1409871007.26422.125.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5408F3FB.2010107@tedp.id.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ted Percival <ted@tedp.id.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:53138 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750974AbaIDX2I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2014 19:28:08 -0400
Received: by mail-pa0-f46.google.com with SMTP id eu11so20906798pac.5
        for <netdev@vger.kernel.org>; Thu, 04 Sep 2014 16:28:08 -0700 (PDT)
In-Reply-To: <5408F3FB.2010107@tedp.id.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-09-04 at 17:21 -0600, Ted Percival wrote:

> # ethtool -k wlan0
> Features for wlan0:
> rx-checksumming: off [fixed]
> tx-checksumming: off
> 	tx-checksum-ipv4: off [fixed]
> 	tx-checksum-ip-generic: off [fixed]
> 	tx-checksum-ipv6: off [fixed]
> 	tx-checksum-fcoe-crc: off [fixed]
> 	tx-checksum-sctp: off [fixed]
> scatter-gather: off
> 	tx-scatter-gather: off [fixed]
> 	tx-scatter-gather-fraglist: off [fixed]
> tcp-segmentation-offload: off
> 	tx-tcp-segmentation: off [fixed]
> 	tx-tcp-ecn-segmentation: off [fixed]
> 	tx-tcp6-segmentation: off [fixed]
> udp-fragmentation-offload: off [fixed]
> generic-segmentation-offload: off [requested on]
> generic-receive-offload: on
> large-receive-offload: off [fixed]
> rx-vlan-offload: off [fixed]
> tx-vlan-offload: off [fixed]
> ntuple-filters: off [fixed]
> receive-hashing: off [fixed]
> highdma: off [fixed]
> rx-vlan-filter: off [fixed]
> vlan-challenged: off [fixed]
> tx-lockless: off [fixed]
> netns-local: on [fixed]
> tx-gso-robust: off [fixed]
> tx-fcoe-segmentation: off [fixed]
> tx-gre-segmentation: off [fixed]
> tx-ipip-segmentation: off [fixed]
> tx-sit-segmentation: off [fixed]
> tx-udp_tnl-segmentation: off [fixed]
> tx-mpls-segmentation: off [fixed]
> fcoe-mtu: off [fixed]
> tx-nocache-copy: off
> loopback: off [fixed]
> rx-fcs: off [fixed]
> rx-all: off [fixed]
> tx-vlan-stag-hw-insert: off [fixed]
> rx-vlan-stag-hw-parse: off [fixed]
> rx-vlan-stag-filter: off [fixed]
> l2-fwd-offload: off [fixed]
> busy-poll: off [fixed]
> 
> # ethtool -K wlan0 tx off
> Cannot change tx-checksumming
> 
> I will try to isolate the commit that caused the regression.

Ah well, I guess we know it ;)

tc -s -d qd show dev wlan0

tc qdisc replace dev wlan0 fq

This should temporarily help.
