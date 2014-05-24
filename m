From: David Miller <davem@davemloft.net>
Subject: Re: randconfig build error with next-20140523,
 in net/bridge/br_netfilter.c
Date: Sat, 24 May 2014 14:24:25 -0400 (EDT)
Message-ID: <20140524.142425.173040092814555368.davem@davemloft.net>
References: <CA+r1Zhjh9Eyyf6uZWfW0beWgOonw77Ewu5w2nRG37698APXREg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	stephen@networkplumber.org, linux-next@vger.kernel.org, pablo@netfilter.org
To: jim.epost@gmail.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <CA+r1Zhjh9Eyyf6uZWfW0beWgOonw77Ewu5w2nRG37698APXREg@mail.gmail.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Jim Davis <jim.epost@gmail.com>
Date: Fri, 23 May 2014 13:06:48 -0700

> Building with the attached random configuration file,
> 
> warning: (BRIDGE_NF_EBTABLES) selects NETFILTER_XTABLES which has
> unmet direct dependencies (NET && INET && NETFILTER)
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

This problem was introduced by:

commit f5efc696cc711021cc73e7543cc3038e58459707
Author: Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>
Date:   Mon Apr 14 15:41:28 2014 +0300

    netfilter: nf_tables: Add meta expression key for bridge interface name

You can't use "select BRIDGE_NETFILTER" for NF_TABLES_BRIDGE, because
it is BRIDGE_NETFILTER which provides the proper dependencies, and
in particular the crucial "INET" dependency.

When you use a hammer like "select" it bypasses the dependencies which
are usually enforced by BRIDGE_NETFILTER and causes the problems we
are seeing here.

Pablo please fix this, thank you.
