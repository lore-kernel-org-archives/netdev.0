From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.14 regression: huge latency in read/select on tun
Date: Thu, 03 Apr 2014 06:50:26 -0700
Message-ID: <1396533026.12330.9.camel@edumazet-glaptop2.roam.corp.google.com>
References: <533C381E.9090103@odi.ch>
	 <1396456973.3989.41.camel@edumazet-glaptop2.roam.corp.google.com>
	 <533D133A.3090008@odi.ch>
	 <1396531176.12330.6.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Ortwin =?ISO-8859-1?Q?Gl=FCck?= <odi@odi.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:63309 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751777AbaDCNu2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2014 09:50:28 -0400
In-Reply-To: <1396531176.12330.6.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-04-03 at 06:19 -0700, Eric Dumazet wrote:

> It seems TSO support is broken.

If bug is in tun.c you have this list of changes  you could bisect
from :

# git log --oneline v3.13..v3.14 drivers/net/tun.c
6671b2240c54 tun: remove bogus hardware vlan acceleration flags from vlan_features
99932d4fc03a netdevice: add queue selection fallback handler for ndo_select_queue
93e14b6d776e tun: add device name(iff) field to proc fdinfo entry
fa35864e0bb7 tuntap: Fix for a race in accessing numqueues
0a379e21c503 Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
fbe4d4565bad tun, rfs: fix the incorrect hash value
9bc8893937c8 tun: Add support for RFS on tun flows
143c90549494 Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
3958afa1b272 net: Change skb_get_rxhash to skb_get_hash
42404c091510 Revert "tun: remove useless codes in tun_chr_aio_read() and tun_recvmsg()"
73713357ab58 tun: remove useless codes in tun_chr_aio_read() and tun_recvmsg()
34f9f437104b Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
f96eb74c84eb tun: remove unused parameter in tun_do_read()
92d4ea6e412a tun: spelling fixes
