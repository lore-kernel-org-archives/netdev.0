From: Thomas Graf <tgraf@suug.ch>
Subject: Re: patch: introduce simple actions
Date: Sun, 20 Mar 2005 20:44:08 +0100
Message-ID: <20050320194408.GU3086@postel.suug.ch>
References: <1111345551.1095.82.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        Patrick McHardy <kaber@trash.net>
To: Jamal Hadi Salim <hadi@znyx.com>
Content-Disposition: inline
In-Reply-To: <1111345551.1095.82.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Jamal Hadi Salim <1111345551.1095.82.camel@jzny.localdomain> 2005-03-20 14:05
> 
> Ive posted this before - dont want it to sit here rotting. 
> If theres nothing glaringly wrong with it (Thomas/Patrick?) then Dave
> please apply so i can start shooting other patches based on it.

Looks good to me, see two minor comments below.

> +static inline int
> +tcf_defact_init(struct rtattr *rta, struct rtattr *est,
> +		struct tc_action *a, int ovr, int bind)
> +{
> +	struct rtattr *tb[TCA_DEF_MAX];
> +	struct tc_defact *parm;
> +	struct tcf_defact *p;
> +	void *defdata;
> +	u32 datalen = 0;
> +	int ret = 0;
> +
> +	if (rta == NULL || rtattr_parse_nested(tb, TCA_DEF_MAX, rta) < 0)
> +		return -EINVAL;
> +
> +	if (tb[TCA_DEF_PARMS - 1] == NULL)
> +		return -EINVAL;
> +	parm = RTA_DATA(tb[TCA_DEF_PARMS - 1]);
> +	defdata = RTA_DATA(tb[TCA_DEF_DATA - 1]);

Maybe do a size sanity check here for TCA_DEF_PARMS?

> +	if (defdata == NULL)
> +		return -EINVAL;
> +
> +	datalen = RTA_PAYLOAD(tb[TCA_DEF_DATA - 1]);
> --- /dev/null	2004-01-29 13:33:32.773091056 -0500
> +++ 2611-rc3+bk3/include/net/tc_act/tc_defact.h	2005-02-06 15:03:05.000000000 -0500
> @@ -0,0 +1,13 @@
> +#ifndef __NET_TC_DEF_H
> +#define __NET_TC_DEF_H
> +
> +#include <net/act_api.h>
> +
> +struct tcf_defact
> +{
> +	tca_gen(defact);
> +	u32     datalen;
> +	void    *defdata;
> +};
> +
> +#endif
> --- /dev/null	2004-01-29 13:33:32.773091056 -0500
> +++ 2611-rc3+bk3/include/linux/tc_act/tc_defact.h	2005-02-06 16:47:20.039209336 -0500
> @@ -0,0 +1,21 @@
> +#ifndef __LINUX_TC_DEF_H
> +#define __LINUX_TC_DEF_H
> +
> +#include <linux/pkt_cls.h>
> +
> +struct tc_defact
> +{
> +	tc_gen;
> +};

tcf_defact, tc_defact, .. quite easy to get this wrong. Maybe
it would a good idea to rename tcf_defact to tcf_defact_parm?
