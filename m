From: Thomas Graf <tgraf@suug.ch>
Subject: Re: instead of eaction
Date: Mon, 7 Feb 2005 00:08:59 +0100
Message-ID: <20050206230859.GY31837@postel.suug.ch>
References: <1107728020.1055.50.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1107728020.1055.50.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1107728020.1055.50.camel@jzny.localdomain> 2005-02-06 17:13
> 
> I think i am going to throw out the idea of eaction; instead
> just provide some defaults.
> First patch adds some defaults and second a quick simple example.
> 
> I have to take off; but maybe i will get time to work on meta action as
> well as csum action when i get back.
> 
> Comments welcome
> 
> cheers,
> jamal

> --- /dev/null	2004-01-29 13:33:32.773091056 -0500
> +++ 2611-rc3+bk3/include/net/act_generic.h	2005-02-06 15:55:36.000000000 -0500
> +	if (rta == NULL || rtattr_parse_nested(tb, TCA_DEF_MAX, rta) < 0)
> +		return -EINVAL;
> +
> +	if (tb[TCA_DEF_PARMS - 1] == NULL)
> +		return -EINVAL;

Maybe check for tb[TCA_DEF_DATA - 1] == NULL here as well?

> +	parm = RTA_DATA(tb[TCA_DEF_PARMS - 1]);

RTA_PAYLOAD check for TCA_DEF_PARMS?

> --- /dev/null	2004-01-29 13:33:32.773091056 -0500
> +++ 2611-rc3+bk3/net/sched/simple.c	2005-02-06 15:55:57.000000000 -0500
> @@ -0,0 +1,107 @@

> +#include <linux/tc_act/tc_defact.h>
> +#include <net/tc_act/tc_defact.h>
> +
> +/* use generic hash table with 8 buckets */
> +#define MY_TAB_SIZE     8
> +#define MY_TAB_MASK     (MY_TAB_SIZE - 1)
> +static u32 idx_gen;
> +static struct tcf_defact *tcf_simp_ht[MY_TAB_SIZE];
> +static DEFINE_RWLOCK(simp_lock);

I guess this is supposed to be tca_use_default_defines
and move MY_TAB_SIZE before the includes?

It looks pretty simple to use and makes up ematches quite well. Any
userspace code alreay written?
