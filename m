From: "Denis V. Lunev" <den@parallels.com>
Subject: Re: [PATCH net-next] Phonet: basic net namespace support
Date: Mon, 01 Dec 2008 15:17:49 +0300
Message-ID: <1228133869.10480.10.camel@iris.sw.ru>
References: <>
	 <1228132957-18373-1-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?ISO-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:37701 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751084AbYLAMRv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Dec 2008 07:17:51 -0500
In-Reply-To: <1228132957-18373-1-git-send-email-remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-12-01 at 14:02 +0200, R=E9mi Denis-Courmont wrote:
[snip]
> -int phonet_address_lookup(u8 addr)
> +int phonet_address_lookup(struct net *net, u8 addr)
>  {
>  	struct phonet_device *pnd;
> =20
>  	spin_lock_bh(&pndevs.lock);
>  	list_for_each_entry(pnd, &pndevs.list, list) {
> +		if (dev_net(pnd->netdev) !=3D net)
> +			continue;
net_eq is better (noop without netns). also there are some similar
places below

Regards,
	Den

