From: =?UTF-8?B?T3J0d2luIEdsw7xjaw==?= <odi@odi.ch>
Subject: Re: 3.14 regression: huge latency in read/select on tun
Date: Fri, 04 Apr 2014 10:34:11 +0200
Message-ID: <533E6E83.7030106@odi.ch>
References: <533C381E.9090103@odi.ch>	 <1396456973.3989.41.camel@edumazet-glaptop2.roam.corp.google.com>	 <533D133A.3090008@odi.ch>	 <1396531176.12330.6.camel@edumazet-glaptop2.roam.corp.google.com> <1396533026.12330.9.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1396533026.12330.9.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 03.04.2014 15:50, Eric Dumazet wrote:
> If bug is in tun.c you have this list of changes  you could bisect
> from :
> 
> # git log --oneline v3.13..v3.14 drivers/net/tun.c
> 6671b2240c54 tun: remove bogus hardware vlan acceleration flags from vlan_features
> 99932d4fc03a netdevice: add queue selection fallback handler for ndo_select_queue
> 93e14b6d776e tun: add device name(iff) field to proc fdinfo entry
> fa35864e0bb7 tuntap: Fix for a race in accessing numqueues
> 0a379e21c503 Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
> fbe4d4565bad tun, rfs: fix the incorrect hash value
> 9bc8893937c8 tun: Add support for RFS on tun flows
> 143c90549494 Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
> 3958afa1b272 net: Change skb_get_rxhash to skb_get_hash
> 42404c091510 Revert "tun: remove useless codes in tun_chr_aio_read() and tun_recvmsg()"
> 73713357ab58 tun: remove useless codes in tun_chr_aio_read() and tun_recvmsg()
> 34f9f437104b Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
> f96eb74c84eb tun: remove unused parameter in tun_do_read()
> 92d4ea6e412a tun: spelling fixes


That list doesn't look too promising. I'd rather look in net/ipv4 which
does have TSO/GSO related changes. I tried to bisect that but the system
hangs on boot when net devices are enabled. So it may prove difficult to
pin down. I may try again during the weekend.
