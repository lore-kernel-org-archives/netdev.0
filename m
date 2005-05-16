From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] [SCHED] Fix unlock spinlock in error path
Date: Mon, 16 May 2005 15:49:00 +0200
Message-ID: <20050516134900.GC13748@postel.suug.ch>
References: <Pine.LNX.4.62.0505161555080.13294@webhosting.rdsbv.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: "Catalin(ux aka Dino) BOIE" <util@deuroconsult.ro>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.62.0505161555080.13294@webhosting.rdsbv.ro>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Catalin(ux aka Dino) BOIE <Pine.LNX.4.62.0505161555080.13294@webhosting.rdsbv.ro> 2005-05-16 16:01
> In act_api.c::tcf_action_copy_stats, in error path (get_stats
> returns < 0), the spinlock taken in gnet_stats_start_copy_compat
> or gnet_stats_start_copy is not unlocked.

This is on purpose, get_stats() is nothing more than a placeholder
at the moment for something that should really be called dump_stats()
and have struct gnet_dump as one of its arguments. The unlocking
must be done in the internal error handling and if we ever have an
operation that could fail between _start() and _stop() for
another reason we'll need a gnet_stats_abort() (skb_trim()'ing
properly) to avoid double unlocking. But since there is no
user of this API yet it doesn't make sense to bloat the code.
