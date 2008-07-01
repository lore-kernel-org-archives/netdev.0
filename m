From: Patrick McHardy <kaber@trash.net>
Subject: Re: v2 [PATCH net-next 1/8] af_packet: Check return of dev_set_promiscuity/allmulti
Date: Tue, 01 Jul 2008 11:36:17 +0200
Message-ID: <4869FA91.30405@trash.net>
References: <4869A251.108@cn.fujitsu.com> <4869A2D5.1010605@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63084 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753892AbYGAJgU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2008 05:36:20 -0400
In-Reply-To: <4869A2D5.1010605@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wang Chen wrote:
> dev_set_promiscuity/allmulti might overflow.
> Commit: "netdevice: Fix promiscuity and allmulti overflow" in net-next makes
> dev_set_promiscuity/allmulti return error number if overflow happened.
> 
> In af_packet, we check all positive increment for promiscuity and allmulti
> to get error return.
> 
>  static void packet_dev_mclist(struct net_device *dev, struct packet_mclist *i, int what)
> @@ -1245,7 +1247,7 @@ static int packet_mc_add(struct sock *sk, struct packet_mreq_max *mreq)
>  	i->count = 1;
>  	i->next = po->mclist;
>  	po->mclist = i;
> -	packet_dev_mc(dev, i, +1);
> +	err = packet_dev_mc(dev, i, 1);

Missing error handling. The packet_mclist is already initialized
and on the list here, which will result in deletion without
addition in packet_flush_mclist().

