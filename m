From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net] dsa: fix promiscuity leak on slave dev open error
Date: Fri, 26 Jun 2015 09:40:06 -0700
Message-ID: <558D8066.5010702@gmail.com>
References: <1435240213-15179-1-git-send-email-giladb@ezchip.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Gilad Ben-Yossef <gilad@benyossef.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Andrew Lunn <andrew@lunn.ch>, Scott Feldman <sfeldma@gmail.com>
To: giladb@ezchip.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:35137 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751888AbbFZQlh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2015 12:41:37 -0400
Received: by pdbci14 with SMTP id ci14so77988174pdb.2
        for <netdev@vger.kernel.org>; Fri, 26 Jun 2015 09:41:36 -0700 (PDT)
In-Reply-To: <1435240213-15179-1-git-send-email-giladb@ezchip.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25/06/15 06:50, giladb@ezchip.com wrote:
> From: Gilad Ben-Yossef <gilad@benyossef.com>
> 
> DSA master netdev promiscuity counter was not being properly
> decremented on slave device open error path.
> 
> Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
> CC: Gilad Ben-Yossef <giladb@ezchip.com>
> CC: David S. Miller <davem@davemloft.net>
> CC: Florian Fainelli <f.fainelli@gmail.com>
> CC: Guenter Roeck <linux@roeck-us.net>
> CC: Andrew Lunn <andrew@lunn.ch>
> CC: Scott Feldman <sfeldma@gmail.com>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

> ---
>  net/dsa/slave.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/dsa/slave.c b/net/dsa/slave.c
> index 04ffad3..0917123 100644
> --- a/net/dsa/slave.c
> +++ b/net/dsa/slave.c
> @@ -112,7 +112,7 @@ static int dsa_slave_open(struct net_device *dev)
>  
>  clear_promisc:
>  	if (dev->flags & IFF_PROMISC)
> -		dev_set_promiscuity(master, 0);
> +		dev_set_promiscuity(master, -1);
>  clear_allmulti:
>  	if (dev->flags & IFF_ALLMULTI)
>  		dev_set_allmulti(master, -1);
> 


-- 
Florian
