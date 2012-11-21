From: Martin Tessun <martin.tessun@gmx.de>
Subject: Re: Packet Corruption with Atheros Communications Inc. AR8121/AR8113/AR8114
 Gigabit or Fast Ethernet (rev b0) Interface
Date: Wed, 21 Nov 2012 20:34:24 +0100
Message-ID: <50AD2CC0.5010806@gmx.de>
References: <50ACEB1D.2020303@gmx.de> <1353518049.2590.41.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.die-tessuns.de ([87.106.49.97]:34570 "EHLO
	s15403472.onlinehome-server.info" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755748Ab2KUTel (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2012 14:34:41 -0500
Received: from chewie.die-tessuns.de (p548F653F.dip.t-dialin.net [84.143.101.63])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(Client did not present a certificate)
	by s15403472.onlinehome-server.info (Postfix) with ESMTPSA id C955C531851A
	for <netdev@vger.kernel.org>; Wed, 21 Nov 2012 20:34:39 +0100 (CET)
In-Reply-To: <1353518049.2590.41.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 21.11.2012 18:14, schrieb Eric Dumazet:
> On Wed, 2012-11-21 at 15:54 +0100, Martin Tessun wrote:
[snip bug description]
>
> Is it only happening for IPv6 traffic, or is it also buggy for IPv4 ?
>
> If you disable tso , does the bug disappear ?
>
>
>

It also happens with IPv4 (usually not so fast as with IPv6):

SCP from client:

$ scp -4 server:/export/no_backup/burn/openSUSE-12.2-DVD-x86_64.iso .
openSUSE-12.2-DVD-x86_64.iso 
 
                  4%  184MB   9.3MB/s   07:37 ETA
Corrupted MAC on input.
Disconnecting: Packet corrupt
openSUSE-12.2-DVD-x86_64.iso 
 
                  4%  193MB   9.2MB/s   07:40 ETA
lost connection

SCP initiated from the server:
$ scp -4 openSUSE-12.2-DVD-x86_64.iso uhura:/tmp
openSUSE-12.2-DVD-x86_64.iso 
 
                  3%  149MB   8.8MB/s   08:10 ETA
Received disconnect from 10.100.14.100: 2: Packet corrupt
lost connection

With TSO disabled:
$ sudo ethtool -K eth0 tso off
$ sudo ethtool -k eth0
Offload parameters for eth0:
rx-checksumming: off
tx-checksumming: on
scatter-gather: on
tcp-segmentation-offload: off
udp-fragmentation-offload: off
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off
rx-vlan-offload: on
tx-vlan-offload: on
ntuple-filters: off
receive-hashing: off

SCP (IPv4) initiated from client:
$ scp -4 server:/export/no_backup/burn/openSUSE-12.2-DVD-x86_64.iso .
openSUSE-12.2-DVD-x86_64.iso 
 
                  2%   93MB  10.4MB/s   06:59 ETA
Corrupted MAC on input.
Disconnecting: Packet corrupt
lost connection

SCP (IPv4) initated from server:
$ scp -4 openSUSE-12.2-DVD-x86_64.iso uhura:/tmp
openSUSE-12.2-DVD-x86_64.iso 
 
                  4%  179MB   9.2MB/s   07:46 ETA
Received disconnect from 10.100.14.100: 2: Packet corrupt
lost connection


Regards,
Martin
