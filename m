From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 2/6] net: dsa: simplify netdevice events handling
Date: Fri, 3 Feb 2017 18:43:35 -0800
Message-ID: <ddcb0439-73f1-fe66-cacb-ab01f2146fe2@gmail.com>
References: <20170203182021.14246-1-vivien.didelot@savoirfairelinux.com>
 <20170203182021.14246-3-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>, cphealy@gmail.com
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:33417 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753332AbdBDCne (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 21:43:34 -0500
In-Reply-To: <20170203182021.14246-3-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 02/03/2017 10:20 AM, Vivien Didelot wrote:
> Simplify the code handling the slave netdevice notifier call by
> providing a dsa_slave_changeupper helper for NETDEV_CHANGEUPPER, and so
> on (only this event is supported at the moment.)
> 
> Return NOTIFY_DONE when we did not care about an event, and NOTIFY_OK
> when we were concerned but no error occurred, as the API suggests.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---

>  static int dsa_slave_netdevice_event(struct notifier_block *nb,
> @@ -1529,8 +1514,11 @@ static int dsa_slave_netdevice_event(struct notifier_block *nb,
>  {
>  	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
>  
> -	if (dsa_slave_dev_check(dev))
> -		return dsa_slave_port_event(dev, event, ptr);
> +	if (dev->netdev_ops != &dsa_slave_netdev_ops)
> +		return NOTIFY_DONE;

Why not keep the dsa_slave_dev_check() here?


-- 
Florian
