From: Dan Aloni <da-x@gmx.net>
Subject: Re: [PATCH] network device renaming sysfs fix
Date: Fri, 15 Aug 2003 19:50:48 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030815165048.GA11014@callisto.yi.org>
References: <20030815111514.GA5228@callisto.yi.org> <20030815093724.519779e6.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, Linux Net-Dev <netdev@oss.sgi.com>,
   Mark Huth <mhuth@mvista.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20030815093724.519779e6.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Aug 15, 2003 at 09:37:24AM -0700, Stephen Hemminger wrote:
> Yes, this is a better fix because it won't break when unregister and free are split
> into seperate steps (coming soon).
> 
> But, do we really need the debug message?  
> Why return an error if you already committed the change? If you get an error,
> then don't rename the network device.
> 
> The class_dev kobject name is 20 chars and IFNAMSIZ is 16, so the solution
> needs to truncate if new_name is not null terminated (all 16 chars long).
> 
> This seems like the best approach:

Agreed.

> diff -Nru a/net/core/dev.c b/net/core/dev.c
> --- a/net/core/dev.c	Fri Aug 15 09:34:11 2003
> +++ b/net/core/dev.c	Fri Aug 15 09:34:11 2003
[patch]
-- 
Dan Aloni
da-x@gmx.net
