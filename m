From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Compat32 setsockopt overzealous conversions
Date: Tue, 7 Sep 2004 14:06:49 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040907140649.42eaa278.davem@davemloft.net>
References: <1094563381.5122.8.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <1094563381.5122.8.camel@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 07 Sep 2004 14:23:00 +0100
David Woodhouse <dwmw2@infradead.org> wrote:

> compat_sys_setsockopt() is a little overzealous about converting 32-bit
> stuff into 64-bit. It should match on level _and_ optname, not just
> optname. Currently it eats the IPV6_V6ONLY sockopt because its value
> (26) happens to match SO_ATTACH_FILTER.
> 
> This makes it at least check 'level' for everything but
> IPT_SO_SET_REPLACE == IPT6_SO_SET_REPLACE, because that does seem to be
> the same in different levels. But do_netfilter_replace() is another can
> of worms entirely -- it doesn't actually work either, because some
> netfilter modules (like ipt_limit) include kernel-only bits which change
> size in the structure they share with userspace. 

Thanks, applied.

I know it's a pain in the ass, but could you cook up
a 2.4.x version?  Thanks.
