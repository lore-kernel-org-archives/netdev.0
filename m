From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Reduce size of rps_sock_flow_sysctl
Date: Thu, 01 Sep 2016 14:13:17 -0700
Message-ID: <1472764397.5439.1.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160901203658.GA4828@fedora-21-dvm>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        =?ISO-8859-1?Q?H=E5kon?= Bugge <haakon.bugge@oracle.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Hans Westgaard Ry <hans.westgaard.ry@oracle.com>,
        "open list:NETWORKING [GENERAL]" <netdev@vger.kernel.org>
To: Johanna Abrahamsson <johanna@mjao.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:35285 "EHLO
        mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753926AbcIAVNU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 17:13:20 -0400
Received: by mail-pa0-f66.google.com with SMTP id cf3so4650119pad.2
        for <netdev@vger.kernel.org>; Thu, 01 Sep 2016 14:13:20 -0700 (PDT)
In-Reply-To: <20160901203658.GA4828@fedora-21-dvm>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-09-01 at 22:37 +0200, Johanna Abrahamsson wrote:
> Reduce size of rps_sock_flow_sysctl to improve readability.
> 
> Signed-off-by: Johanna Abrahamsson <johanna@mjao.org>
> ---
>  net/core/sysctl_net_core.c | 44 ++++++++++++++++++++++----------------------
>  1 file changed, 22 insertions(+), 22 deletions(-)
> 
> diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
> index 0df2aa6..d0be2ce 100644
> --- a/net/core/sysctl_net_core.c
> +++ b/net/core/sysctl_net_core.c
> @@ -53,29 +53,29 @@ static int rps_sock_flow_sysctl(struct ctl_table *table, int write,
>  	ret = proc_dointvec(&tmp, write, buffer, lenp, ppos);
>  
>  	if (write) {
> -		if (size) {
> -			if (size > 1<<29) {
> -				/* Enforce limit to prevent overflow */
> -				mutex_unlock(&sock_flow_mutex);
> -				return -EINVAL;
> +		if (!size)
> +			goto exit_unlock;

Hi Johanna

Unfortunately this would break the following action :

lpaa24:~# cat /proc/sys/net/core/rps_sock_flow_entries 
65536
lpaa24:~# echo 0 >/proc/sys/net/core/rps_sock_flow_entries
lpaa24:~# cat /proc/sys/net/core/rps_sock_flow_entries 
0

If you resubmit a V2, please include a 'Tested:' section showing how
you have tested your (first linux ?) patch ;)

Thanks !
