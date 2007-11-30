From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCHv7 2/5] rtnetlink: send a single notification on device
 state changes
Date: Sat, 01 Dec 2007 00:24:41 +0100
Message-ID: <47509BB9.10108@o2.pl>
References: <11963527094077-git-send-email-panther@balabit.hu> <11963527103201-git-send-email-panther@balabit.hu> <1196352710402-git-send-email-panther@balabit.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Laszlo Attila Toth <panther@balabit.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx12.go2.pl ([193.17.41.142]:44923 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755827AbXK3XXN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Nov 2007 18:23:13 -0500
In-Reply-To: <1196352710402-git-send-email-panther@balabit.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Laszlo Attila Toth wrote, On 11/29/2007 05:11 PM:

> In do_setlink() a single ntification is sent at the end of the function
> if any modification occured. If the address has been changed, another
> notification is sent.


...

> @@ -858,6 +859,7 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
>  	if (tb[IFLA_BROADCAST]) {
>  		nla_memcpy(dev->broadcast, tb[IFLA_BROADCAST], dev->addr_len);
>  		send_addr_notify = 1;
> +		modified = 1;
>  	}

...

>  	if (send_addr_notify)
>  		call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
> +
> +	if (modified)
> +		netdev_state_change(dev);
> +

The subject suggests there might be less notifications. The patch actually
adds a little. Any additional comment why they are necessary?

Jarek P.
