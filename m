From: Alexey Dobriyan <adobriyan@sw.ru>
Subject: Re: [PATCH 1/5] netns netfilter: per-netns ip6tables
Date: Fri, 25 Jan 2008 19:39:40 +0300
Message-ID: <20080125163940.GD6028@localhost.sw.ru>
References: <20080124122328.GA27337@localhost.sw.ru> <4798CBF1.205@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	devel@openvz.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4798CBF1.205@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 24, 2008 at 06:33:37PM +0100, Patrick McHardy wrote:
> Alexey Dobriyan wrote:
> >* Propagate netns from userspace down to xt_find_table_lock()
> >* Register ip6 tables in netns (modules still use init_net)
> >
> >Signed-off-by: Alexey Dobriyan <adobriyan@sw.ru>
> >---
> >
> > include/linux/netfilter_ipv6/ip6_tables.h |    3 +
> > net/ipv6/netfilter/ip6_tables.c           |   50 
> > +++++++++++++++---------------
> > net/ipv6/netfilter/ip6table_filter.c      |    2 -
> > net/ipv6/netfilter/ip6table_mangle.c      |    2 -
> > net/ipv6/netfilter/ip6table_raw.c         |    2 -
> > 5 files changed, 31 insertions(+), 28 deletions(-)
> 
> This adds checkpatch warnings:
> 
> WARNING: line over 80 characters
> #96: FILE: net/ipv6/netfilter/ip6_tables.c:1361:
> +do_add_counters(struct net *net, void __user *user, unsigned int len, 
> int compat)
> 
> WARNING: line over 80 characters
> #229: FILE: net/ipv6/netfilter/ip6table_filter.c:135:
> +       packet_filter = ip6t_register_table(&init_net, &__packet_filter, 
> &initial_table.repl);
> 
> WARNING: line over 80 characters
> #242: FILE: net/ipv6/netfilter/ip6table_mangle.c:167:
> +       packet_mangler = ip6t_register_table(&init_net, 
> &__packet_mangler, &initial_table.repl);
> 
> WARNING: line over 80 characters
> #255: FILE: net/ipv6/netfilter/ip6table_raw.c:80:
> +       packet_raw = ip6t_register_table(&init_net, &__packet_raw, 
> &initial_table.repl);
> 
> ERROR: Missing Signed-off-by: line(s)

Well, SOB line definitely was present.

> total: 1 errors, 4 warnings, 214 lines checked
> 
> I'll fix them up, lets hope that it doesn't cause clashes
> with the following patches.

OK. It was quantum coding style violation. :-)

