From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] netfilter: bridge: fix Kconfig unmet
 dependencies
Date: Mon, 26 May 2014 00:42:54 -0400 (EDT)
Message-ID: <20140526.004254.830467668632986669.davem@davemloft.net>
References: <1401022113-6430-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1401022113-6430-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Sun, 25 May 2014 14:48:33 +0200

> Before f5efc69 ("netfilter: nf_tables: Add meta expression key for
> bridge interface name"), the entire net/bridge/netfilter/ directory
> depended on BRIDGE_NF_EBTABLES, ie. on ebtables. However, that
> directory already contained the nf_tables bridge extension that
> we should allow to compile separately. In f5efc69, we tried to
> generalize this by using CONFIG_BRIDGE_NETFILTER which was not a good
> idea since this option already existed and it is dedicated to enable
> the Netfilter bridge IP/ARP filtering.
> 
> Let's try to fix this mess by:
> 
> 1) making net/bridge/netfilter/ dependent on the toplevel
>    CONFIG_NETFILTER option, just like we do with the net/netfilter and
>    net/ipv{4,6}/netfilter/ directories.
> 
> 2) Changing 'selects' to 'depends on' NETFILTER_XTABLES for
>    BRIDGE_NF_EBTABLES. I believe this problem was already before
>    f5efc69:
> 
> warning: (BRIDGE_NF_EBTABLES) selects NETFILTER_XTABLES which has
> unmet direct dependencies (NET && INET && NETFILTER)
> 
> 3) Fix ebtables/nf_tables bridge dependencies by making NF_TABLES_BRIDGE
>    and BRIDGE_NF_EBTABLES dependent on BRIDGE and NETFILTER:
> 
> warning: (NF_TABLES_BRIDGE && BRIDGE_NF_EBTABLES) selects
> BRIDGE_NETFILTER which has unmet direct dependencies (NET && BRIDGE &&
> NETFILTER && INET && NETFILTER_ADVANCED)
> 
> net/built-in.o: In function `br_parse_ip_options':
> br_netfilter.c:(.text+0x4a5ba): undefined reference to `ip_options_compile'
> br_netfilter.c:(.text+0x4a5ed): undefined reference to `ip_options_rcv_srr'
> net/built-in.o: In function `br_nf_pre_routing_finish':
> br_netfilter.c:(.text+0x4a8a4): undefined reference to `ip_route_input_noref'
> br_netfilter.c:(.text+0x4a987): undefined reference to `ip_route_output_flow'
> make: *** [vmlinux] Error 1
> 
> Reported-by: Jim Davis <jim.epost@gmail.com>
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
> ---
> @David: Please, feel free to pick this fix into your net-next, it addresses
> http://marc.info/?l=linux-netdev&m=140095588506382&w=2

Applied thanks a lot Pablo.
