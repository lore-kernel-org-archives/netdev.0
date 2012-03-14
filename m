From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net V2] bonding: send igmp report for its master
Date: Wed, 14 Mar 2012 21:58:46 +0800
Message-ID: <4F60A416.30903@gmail.com>
References: <f5d199e12d78dadcfb932e103984276d36b186e0.1331539261.git.panweiping3@gmail.com> <f5d199e12d78dadcfb932e103984276d36b186e0.1331539261.git.panweiping3@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, andy@greyhouse.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Weiping Pan <panweiping3@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f52.google.com ([209.85.210.52]:49176 "EHLO
	mail-pz0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964940Ab2CNN6z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Mar 2012 09:58:55 -0400
In-Reply-To: <f5d199e12d78dadcfb932e103984276d36b186e0.1331539261.git.panweiping3@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/14/2012 11:37 AM, Weiping Pan wrote:
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 435984a..300c490 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -794,6 +794,14 @@ static void bond_resend_igmp_join_requests_delayed(struct work_struct *work)
>   {
>   	struct bonding *bond = container_of(work, struct bonding,
>   					    mcast_work.work);
> +	struct net_device *bond_dev, *master_dev = NULL;
> +	bond_dev = bond->dev;

IIRC, you need to hold read_lock for this...
