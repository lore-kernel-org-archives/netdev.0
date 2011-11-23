From: ShanWei <davidshan@foxmail.com>
Subject: Re: [patch v2 1/1] fix error handle in ip_mc_add_src()
Date: Wed, 23 Nov 2011 16:25:01 +0800
Message-ID: <4ECCADDD.5040606@foxmail.com>
References: <1321891516.14281.62.camel@barry.pixelworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Eric Dumazet <eric.dumazet@gmail.com>,
	netdev@vger.kernel.org, David Stevens <dlstevens@us.ibm.com>
To: Jun Zhao <mypopydev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg52.qq.com ([64.71.138.43]:53724 "HELO smtpbg52.qq.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752426Ab1KWIZK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Nov 2011 03:25:10 -0500
In-Reply-To: <1321891516.14281.62.camel@barry.pixelworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jun Zhao said, at 2011/11/22 0:05:
> from: Jun Zhao<mypopydev@gmail.com>
>
> When add sources to interface failure, need to roll back the sfcount[MODE]
> to before state. We need to match it corresponding.
>
> Acked-by: David L Stevens<dlstevens@us.ibm.com>
> Acked-by: Eric Dumazet<eric.dumazet@gmail.com>
> Signed-off-by: Jun Zhao<mypopydev@gmail.com>
> ---
> diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
> index c7472ef..b2ca095 100644
> --- a/net/ipv4/igmp.c
> +++ b/net/ipv4/igmp.c
> @@ -1716,7 +1716,8 @@ static int ip_mc_add_src(struct in_device *in_dev, __be32 *pmca, int sfmode,
>          if (err) {
>                  int j;
>
> -               pmc->sfcount[sfmode]--;
> +               if (!delta)
> +                       pmc->sfcount[sfmode]--;

Tab is changed to space by your email client.
