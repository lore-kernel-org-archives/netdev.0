From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH v3 net-next 3/5] net: vrf: call
 netdev_lockdep_set_classes()
Date: Thu, 9 Jun 2016 09:05:12 -0600
Message-ID: <dbf12e0e-a4b6-f5f2-ff1c-3e2d52371fab@cumulusnetworks.com>
References: <1465483515-10821-1-git-send-email-edumazet@google.com>
 <1465483515-10821-4-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>,
	"David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:35470 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751469AbcFIPFO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 11:05:14 -0400
Received: by mail-pa0-f46.google.com with SMTP id hl6so13621525pac.2
        for <netdev@vger.kernel.org>; Thu, 09 Jun 2016 08:05:14 -0700 (PDT)
In-Reply-To: <1465483515-10821-4-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/9/16 8:45 AM, Eric Dumazet wrote:
> In case a qdisc is used on a vrf device, we need to use different
> lockdep classes to avoid false positives.
>
> Use the new netdev_lockdep_set_classes() generic helper.
>
> Reported-by: David Ahern <dsa@cumulusnetworks.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  drivers/net/vrf.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
> index e3e693bf0dec..b82e3527924e 100644
> --- a/drivers/net/vrf.c
> +++ b/drivers/net/vrf.c
> @@ -661,7 +661,7 @@ static int vrf_dev_init(struct net_device *dev)
>
>  	/* similarly, oper state is irrelevant; set to up to avoid confusion */
>  	dev->operstate = IF_OPER_UP;
> -
> +	netdev_lockdep_set_classes(dev);
>  	return 0;
>
>  out_rth:
>

Works for me. Thanks, Eric.

Tested-by: David Ahern <dsa@cumulusnetworks.com>
