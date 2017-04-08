From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net_sched: allow configuring default qdisc
Date: Sat, 08 Apr 2017 12:12:44 -0700
Message-ID: <1491678764.10124.96.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170408185025.2104-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        Stephen Hemminger <sthemmin@microsoft.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:33018 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751543AbdDHTMr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Apr 2017 15:12:47 -0400
Received: by mail-io0-f194.google.com with SMTP id w130so117299iow.0
        for <netdev@vger.kernel.org>; Sat, 08 Apr 2017 12:12:46 -0700 (PDT)
In-Reply-To: <20170408185025.2104-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2017-04-08 at 14:50 -0400, Stephen Hemminger wrote:
> Since 3.12 it has been possible to configure the default queuing discipline
> via sysctl. This patch adds ability to configure the default queue discipline
> in kernel configuration. This is useful for environments where configuring
> the value from userspace is difficult to manage.
> 
> The default is still the same as before (pfifo_fast) and it is possible
> to change after kernel init with sysctl.  This is analagous to how
> TCP congestion control is configured.
> 
> Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
> ---
>  net/sched/Kconfig   | 31 +++++++++++++++++++++++++++++++
>  net/sched/sch_api.c |  7 +++++++
>  2 files changed, 38 insertions(+)
> 
> diff --git a/net/sched/Kconfig b/net/sched/Kconfig
> index 403790cce7d2..8fb45655e59b 100644
> --- a/net/sched/Kconfig
> +++ b/net/sched/Kconfig
> @@ -820,6 +820,37 @@ config NET_CLS_IND
>  	  classification based on the incoming device. This option is
>  	  likely to disappear in favour of the metadata ematch.
>  
> +choice
> +	prompt "Default queuing discipline"
> +	default DEFAULT_PFIFO
> +	help
> +	  Select the queueing discipline that will be used by default
> +	  for all network devices.
> +
> +	config DEFAULT_FQ
> +		bool "Fair Queue" if NET_SCH_FQ
> +
> +	config DEFAULT_FQ_CODEL
> +		bool "Fair Queue Controlled Delay (FQ_CODEL)" if NET_SCH_FQ_CODEL
> +
> +	config DEFAULT_CODEL
> +		bool "Controlled Delay (CODEL)" if NET_SCH_CODEL
> +
> +	config DEFAULT_SFQ
> +		bool "Stochastic Fair Queue (SFQ)" if NET_SCH_SFQ
> +
> +	config DEFAULT_PFIFO
> +		bool "Priority FIFO"
> +endchoice
> +
> +config DEFAULT_NET_SCH
> +	string
> +	default "pfifo" if DEFAULT_PFIFO
> +	default "fq" if DEFAULT_FQ
> +	default "fq_codel" if DEFAULT_FQ_CODEL
> +	default "sfq" if DEFAULT_SFQ
> +	default "pfifo"
> +
>  endif # NET_SCHED


Note that pfifo != pfifo_fast

We probably still want pfifo_fast being the default ?
