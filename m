From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 1/2] 6lowpan: reassembly: fix return of init
 function
Date: Thu, 06 Mar 2014 01:04:20 +0300
Message-ID: <53179F64.4060501@cogentembedded.com>
References: <1394052211-6976-1-git-send-email-alex.aring@gmail.com> <1394052211-6976-2-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dbaryshkov@gmail.com, linux-zigbee-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: Alexander Aring <alex.aring@gmail.com>,
	alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:51861 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755867AbaCEVET (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2014 16:04:19 -0500
Received: by mail-lb0-f175.google.com with SMTP id w7so1091128lbi.6
        for <netdev@vger.kernel.org>; Wed, 05 Mar 2014 13:04:16 -0800 (PST)
In-Reply-To: <1394052211-6976-2-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 03/05/2014 11:43 PM, Alexander Aring wrote:

> This patch adds a missing return after fragmentation init. Otherwise we
> register a sysctl interface and deregister it afterwards which makes no
> sense.

> Signed-off-by: Alexander Aring <alex.aring@gmail.com>
> ---
>   net/ieee802154/reassembly.c | 2 ++
>   1 file changed, 2 insertions(+)

> diff --git a/net/ieee802154/reassembly.c b/net/ieee802154/reassembly.c
> index 4511fc2..59db7b5 100644
> --- a/net/ieee802154/reassembly.c
> +++ b/net/ieee802154/reassembly.c
> @@ -550,6 +550,8 @@ int __init lowpan_net_frag_init(void)
>   	lowpan_frags.frag_expire = lowpan_frag_expire;
>   	lowpan_frags.secret_interval = 10 * 60 * HZ;
>   	inet_frags_init(&lowpan_frags);
> +
> +	return 0;

    Perhaps 'goto out' for "consistency" with the code above? (I don't know 
why they used "goto out' in the first place.)

>   err_pernet:
>   	lowpan_frags_sysctl_unregister();
>   out:

WBR, Sergei
