From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net 2/2] ip6tnl: allow to use rtnl ops on fb tunnel
Date: Wed, 02 Oct 2013 09:16:57 +0200
Message-ID: <524BC869.1060109@6wind.com>
References: <524AB26B.1070700@6wind.com>	<1380643500-5018-1-git-send-email-nicolas.dichtel@6wind.com>	<1380643500-5018-2-git-send-email-nicolas.dichtel@6wind.com> <20131001.125942.775476054819333568.davem@davemloft.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com,
	pshelar@nicira.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f48.google.com ([74.125.82.48]:59566 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752895Ab3JBHQ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Oct 2013 03:16:59 -0400
Received: by mail-wg0-f48.google.com with SMTP id n12so417070wgh.27
        for <netdev@vger.kernel.org>; Wed, 02 Oct 2013 00:16:58 -0700 (PDT)
In-Reply-To: <20131001.125942.775476054819333568.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 01/10/2013 18:59, David Miller a =E9crit :
> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Date: Tue,  1 Oct 2013 18:05:00 +0200
>
>> rtnl ops where introduced by c075b13098b3 ("ip6tnl: advertise tunnel=
 param via
>> rtnl"), but I forget to assign rtnl ops to fb tunnels.
>>
>> Now that it is done, we must remove the explicit call to
>> unregister_netdevice_queue(), because  the fallback tunnel is added =
to the queue
>> in ip6_tnl_destroy_tunnels() when checking rtnl_link_ops of all netd=
evices (this
>> is valid since commit 0bd8762824e7 ("ip6tnl: add x-netns support")).
>>
>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>
> Applied and queued up for -stable, and I have similar concerns about
> the backport issues.
>
> Thanks.
>
Yes, same here: before the x-netns changes, we must keep the=20
unregister_netdevice_queue() line.
