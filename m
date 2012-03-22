From: Rusty Russell <rusty@rustcorp.com.au>
Subject: re: module_param: make bool parameters really bool (net & drivers/net)
Date: Fri, 23 Mar 2012 08:37:09 +1030
Message-ID: <8762dw9to2.fsf@rustcorp.com.au>
References: <20120322182623.GA29859@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120322182623.GA29859@elgon.mountain>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 22 Mar 2012 21:26:23 +0300, Dan Carpenter <dan.carpenter@oracle.com> wrote:
> Hi Rusty,
> 
> The patch eb93992207da: "module_param: make bool parameters really
> bool (net & drivers/net)" from Dec 19, 2011, leads to the following
> warning:
> net/ipv4/netfilter/iptable_filter.c:90 iptable_filter_init()
> 	warn: 5 is more than 1 (max 'forward' can be) so this is
> 	always the same.
> 
> It's declared like this:
> 
>     54  /* Default to forward because I got too much mail already. */
>     55  static bool forward = NF_ACCEPT;
>     56  module_param(forward, bool, 0000);
> 
> 
> It's used like this:
>     66          ((struct ipt_standard *)repl->entries)[1].target.verdict = -forward - 1;
> 
> Smatch complains when check that it's larger than 5.
> 
>     90          if (forward < 0 || forward > NF_MAX_VERDICT) {
>     91                  pr_err("iptables forward must be 0 or 1\n");
>     92                  return -EINVAL;
>     93          }

Thanks Dan!

        This was obviously initially an arbitrary value, but someone
made it a bool module parameter (me?).  It works for accept and drop, so
let's make it official.  Patch coming.

Thanks,
Rusty.
-- 
  How could I marry someone with more hair than me?  http://baldalex.org
