From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [PATCH net-next] ipv4: fib: Replay events when registering FIB
 notifier
Date: Mon, 31 Oct 2016 11:03:37 +0200
Message-ID: <20161031090337.q4srbalxqdw4bd3o@splinter>
References: <1477902578-20137-1-git-send-email-idosch@idosch.org>
 <201611010030.QbB5pF6n%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, netdev@vger.kernel.org, davem@davemloft.net,
        jiri@mellanox.com, mlxsw@mellanox.com, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, dsa@cumulusnetworks.com,
        andy@greyhouse.net, alexander.h.duyck@intel.com,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        andrew@lunn.ch, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net,
        Ido Schimmel <idosch@mellanox.com>
To: kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:34011 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1763376AbcJaJDl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 05:03:41 -0400
Content-Disposition: inline
In-Reply-To: <201611010030.QbB5pF6n%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 01, 2016 at 12:54:01AM +0800, kbuild test robot wrote:
> Hi Ido,
> 
> [auto build test ERROR on net-next/master]
> 
> url:    https://github.com/0day-ci/linux/commits/idosch-idosch-org/ipv4-fib-Replay-events-when-registering-FIB-notifier/20161031-163334
> config: x86_64-randconfig-x014-201644 (attached as .config)
> compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 
> 
> All errors (new ones prefixed by >>):
> 
>    net/ipv4/fib_trie.c: In function 'register_fib_notifier':
> >> net/ipv4/fib_trie.c:141:16: error: 'struct netns_ipv4' has no member named 'fib_has_custom_rules'
>       if (net->ipv4.fib_has_custom_rules)
>                    ^
>    net/ipv4/fib_trie.c: In function 'unregister_fib_notifier':
>    net/ipv4/fib_trie.c:178:16: error: 'struct netns_ipv4' has no member named 'fib_has_custom_rules'
>       if (net->ipv4.fib_has_custom_rules)
>                    ^

Right, I missed that. Will send a v2.

Thanks!

> 
> vim +141 net/ipv4/fib_trie.c
> 
>    135		err = blocking_notifier_chain_register(&fib_chain, nb);
>    136		if (err)
>    137			goto unlock;
>    138		for_each_net(net) {
>    139			struct fib_notifier_info info;
>    140	
>  > 141			if (net->ipv4.fib_has_custom_rules)
>    142				call_fib_notifier(nb, net, FIB_EVENT_RULE_ADD, &info);
>    143			fib_notify(net, nb, FIB_EVENT_ENTRY_ADD);
>    144		}
> 
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
