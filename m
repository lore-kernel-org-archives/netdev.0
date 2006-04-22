From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Hotplug race on name change
Date: Sat, 22 Apr 2006 10:28:44 +1000
Message-ID: <E1FX5zQ-000177-00@gondolin.me.apana.org.au>
References: <20060421102503.4e44eb28@localhost.localdomain>
Cc: patrakov@ums.usu.ru, netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:268 "EHLO arnor.apana.org.au")
	by vger.kernel.org with ESMTP id S1750782AbWDVA3f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2006 20:29:35 -0400
To: shemminger@osdl.org (Stephen Hemminger)
In-Reply-To: <20060421102503.4e44eb28@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@osdl.org> wrote:
> 
> Introduces new races in netdev_register_sysfs if the name changes, because
> netdev_register_sysfs runs without RTNL at this point. So if some application gets
> in and changes the device name while netdev_register_sysfs is running, then
> the class_dev->class_id would end up not matching the netdevice->name.

Indeed.  It also seems to be possible now for someone to do an
unregister_netdevice while netdev_register_sysfs is still going.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
