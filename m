From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [PATCH 01/20] net: NETDEV_UNREGISTER_PERNET -> NETDEV_UNREGISTER_BATCH
Date: Mon, 30 Nov 2009 14:08:33 +0200
Message-ID: <200911301408.33297.opurdila@ixiacom.com>
References: <1259545577-7466-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jamal <hadi@cyberus.ca>, Daniel Lezcano <dlezcano@fr.ibm.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Patrick McHardy <kaber@trash.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:26468 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751277AbZK3MLj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 07:11:39 -0500
In-Reply-To: <1259545577-7466-1-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 30 November 2009 03:45:58 you wrote:

> +       /* Process any work delayed until the end of the batch */
> +       dev = list_entry(head->next, struct net_device, unreg_list);
> +       call_netdevice_notifiers(NETDEV_UNREGISTER_BATCH, dev);
>  
> -       list_for_each_entry_safe(dev, aux, head, unreg_list) {
> -               int new_net = 1;
> -               list_for_each_entry(fdev, &pernet_list, unreg_list) {
> -                       if (net_eq(dev_net(dev), dev_net(fdev))) {
> -                               new_net = 0;
> -                               dev_put(dev);
> -                               break;
> -                       }
> -               }
> -               if (new_net)
> -                       list_move(&dev->unreg_list, &pernet_list);
> -       }
> 

This implies that the devices we want to batch unregister needs to be part of 
the same namespace. It might be worth mentioning that in the 
unregister_netdevice_many() function comments.

And, fortunately, it seems that all of the current batch unregister users 
comply with this requirement.

