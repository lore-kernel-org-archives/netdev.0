From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: PATCH iproute2] catch iptables interface changes
Date: Mon, 6 May 2013 18:53:43 +0200
Message-ID: <20130506165343.GA9077@localhost>
References: <517D35D6.8090606@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jan Engelhardt <jengelh@inai.de>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35944 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753109Ab3EFQxt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 May 2013 12:53:49 -0400
Content-Disposition: inline
In-Reply-To: <517D35D6.8090606@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 28, 2013 at 10:44:38AM -0400, Jamal Hadi Salim wrote:
> commit ba9b18dbcad853e22ea2b8ecf87d53ef2f6cf58c
> Author: Jamal Hadi Salim <jhs@mojatatu.com>
> Date:   Sun Apr 28 07:41:47 2013 -0400
> 
>     Detect future iptable changes interfaces earlier in the dev
>     cycles. Hopefully someone is going to complain about such breakage
>     and we'll get the fix in sooner.
>     
>     Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
> 
> diff --git a/tc/m_xt.c b/tc/m_xt.c
> index 3edf520..b266337 100644
> --- a/tc/m_xt.c
> +++ b/tc/m_xt.c
> @@ -129,6 +129,10 @@ static int parse_ipt(struct action_util *a,int *argc_p,
>  	__u32 hook = 0, index = 0;
>  	struct option *opts = NULL;
>  
> +#if (XTABLES_VERSION_CODE > 7)
> +#error Someone call the guy who changed xtables ver 7 and \
> +	make him fix it^W^W^W^W say you need help.
> +#endif

BTW, iptables 1.4.19 (that will be released soon) will be
XTABLES_VERSION_CODE == 10:

libxtables_vcurrent=10
libxtables_vage=0

XTABLES_VERSION_CODE = libxtables_vcurrent - libxtables_vage

iptables 1.4.19 -> 10
iptables 1.4.18 -> 10
iptables 1.4.17 -> 9
iptables 1.4.16.3 -> 9
[ seems like we have skip one by accident ]
iptables 1.4.15 -> 7

So this error that Jamal proposes will be hit soon again by users. But
I don't think all those API updates affect xt action though. There is
a limited amount of functions that xt action uses.

Let me think if I can come with a better idea.

Regards.
