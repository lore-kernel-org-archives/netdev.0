From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2 2/2] sctp: optimize the sctp_sysctl_net_register
Date: Tue, 11 Feb 2014 19:47:20 +0300
Message-ID: <52FA5418.6090007@cogentembedded.com>
References: <1392083346-9420-1-git-send-email-wangweidong1@huawei.com> <1392083346-9420-3-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, netdev@vger.kernel.org
To: Wang Weidong <wangweidong1@huawei.com>, nhorman@tuxdriver.com,
	davem@davemloft.net, vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:34573 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750782AbaBKPrX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Feb 2014 10:47:23 -0500
Received: by mail-la0-f53.google.com with SMTP id e16so6099249lan.12
        for <netdev@vger.kernel.org>; Tue, 11 Feb 2014 07:47:22 -0800 (PST)
In-Reply-To: <1392083346-9420-3-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 02/11/2014 04:49 AM, Wang Weidong wrote:

> Here, when the net is init_net, we needn't to kmemdup the ctl_table
> again. So add a check for net. Also we can save some memory.

> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
> ---
>   net/sctp/sysctl.c | 16 +++++++++-------
>   1 file changed, 9 insertions(+), 7 deletions(-)

> diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
> index 2ddb401..b65396b 100644
> --- a/net/sctp/sysctl.c
> +++ b/net/sctp/sysctl.c
> @@ -403,15 +403,17 @@ static int proc_sctp_do_rto_max(struct ctl_table *ctl, int write,
>
>   int sctp_sysctl_net_register(struct net *net)
>   {
> -	struct ctl_table *table;
> -	int i;
> +	struct ctl_table *table = sctp_net_table;
>
> -	table = kmemdup(sctp_net_table, sizeof(sctp_net_table), GFP_KERNEL);
> -	if (!table)
> -		return -ENOMEM;
> +	if (!net_eq(net, &init_net)) {
> +		int i;

    Empty line after declaration wouldn't hurt, just like above.

> +		table = kmemdup(sctp_net_table, sizeof(sctp_net_table), GFP_KERNEL);
> +		if (!table)
> +			return -ENOMEM;

WBR, Sergei
