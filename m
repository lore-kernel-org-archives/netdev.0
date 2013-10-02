From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net 1/2] sit: allow to use rtnl ops on fb tunnel
Date: Wed, 02 Oct 2013 09:15:34 +0200
Message-ID: <524BC816.1000702@6wind.com>
References: <524AB26B.1070700@6wind.com>	<1380643500-5018-1-git-send-email-nicolas.dichtel@6wind.com> <20131001.125923.700243113980583930.davem@davemloft.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com,
	pshelar@nicira.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:34268 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752743Ab3JBHPk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Oct 2013 03:15:40 -0400
Received: by mail-wg0-f49.google.com with SMTP id l18so418979wgh.16
        for <netdev@vger.kernel.org>; Wed, 02 Oct 2013 00:15:39 -0700 (PDT)
In-Reply-To: <20131001.125923.700243113980583930.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 01/10/2013 18:59, David Miller a =E9crit :
> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Date: Tue,  1 Oct 2013 18:04:59 +0200
>
>> rtnl ops where introduced by ba3e3f50a0e5 ("sit: advertise tunnel pa=
ram via
>> rtnl"), but I forget to assign rtnl ops to fb tunnels.
>>
>> Now that it is done, we must remove the explicit call to
>> unregister_netdevice_queue(), because  the fallback tunnel is added =
to the queue
>> in sit_destroy_tunnels() when checking rtnl_link_ops of all netdevic=
es (this
>> is valid since commit 5e6700b3bf98 ("sit: add support of x-netns")).
>>
>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>
> Applied and queued up for -stable.
>
> But I imagine since the x-netns changes aren't in various -stable
> branches this will need to be adjusted a bit?
Yes, it's what I've tried to say in the commit log ;-)

In fact, before the x-netns changes, we must keep the=20
unregister_netdevice_queue() line.
