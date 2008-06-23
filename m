From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] IRDA: Fix genlmsg_put() return value check.
Date: Tue, 24 Jun 2008 01:54:47 +0200
Message-ID: <486037C7.6010409@trash.net>
References: <1214248629-6208-1-git-send-email-juliusv@google.com>	 <485FFCE3.2050800@trash.net> <f4845fc0806231329p7ef94a8dqafe63feea89ad949@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, samuel@sortiz.org, netdev@vger.kernel.org
To: Julius Volz <juliusv@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:65510 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751727AbYFWXyx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2008 19:54:53 -0400
In-Reply-To: <f4845fc0806231329p7ef94a8dqafe63feea89ad949@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Julius Volz wrote:
> On Mon, Jun 23, 2008, Patrick McHardy wrote:
>> Good catch, but the correct return value for insufficient
>> space in the skb is -ENOSPC.
> 
> Hm, seems we have many inconsistent values returned in exactly this
> situation (in response to genlmsg_put), but none of them are -ENOSPC:
> 
> fs/dlm/netlink.c: -EINVAL
> net/netlink/genetlink.c: -1
> net/netlabel/netlabel_unlabeled.c: -ENOMEM
> net/netlabel/netlabel_cipso_v4.c: -ENOMEM
> net/netlabel/netlabel_mgmt.c: -ENOMEM
> net/wireless/nl80211.c: -1
> drivers/acpi/event.c: -ENOMEM
> kernel/taskstats.c: -EINVAL
> 
> Seems like -ENOMEM is most common, don't know if that means it's
> correct, though...
> 
> I was also using -ENOMEM in my Netlink code, so better convert all my
> new uses to -ENOSPC?

Yes, all those should be using ENOSPC as well. nl80211 returns
inconsistent errors currently (-1/EMSGSIZE), but doesn't propagate
them back to userspace. That should probably be fixed as well.

Actually I was wrong, its EMSGSIZE, not ENOSPC that should be
returned, its more fitting and what other netlink users do as
well.

