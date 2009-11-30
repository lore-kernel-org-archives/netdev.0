From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [PATCH 01/20] net: NETDEV_UNREGISTER_PERNET -> NETDEV_UNREGISTER_BATCH
Date: Mon, 30 Nov 2009 21:25:42 +0200
Message-ID: <200911302125.42439.opurdila@ixiacom.com>
References: <1259545577-7466-1-git-send-email-ebiederm@xmission.com> <200911301408.33297.opurdila@ixiacom.com> <m1hbsb7s86.fsf@fess.ebiederm.org>
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
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:2901 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752430AbZK3T2t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 14:28:49 -0500
In-Reply-To: <m1hbsb7s86.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 30 November 2009 21:00:41 you wrote:
> Octavian Purdila <opurdila@ixiacom.com> writes:
> > On Monday 30 November 2009 03:45:58 you wrote:
> >> +       /* Process any work delayed until the end of the batch */
> >> +       dev = list_entry(head->next, struct net_device, unreg_list);
> >> +       call_netdevice_notifiers(NETDEV_UNREGISTER_BATCH, dev);
> >>
> >> -       list_for_each_entry_safe(dev, aux, head, unreg_list) {
> >> -               int new_net = 1;
> >> -               list_for_each_entry(fdev, &pernet_list, unreg_list) {
> >> -                       if (net_eq(dev_net(dev), dev_net(fdev))) {
> >> -                               new_net = 0;
> >> -                               dev_put(dev);
> >> -                               break;
> >> -                       }
> >> -               }
> >> -               if (new_net)
> >> -                       list_move(&dev->unreg_list, &pernet_list);
> >> -       }
> >
> > This implies that the devices we want to batch unregister needs to be
> > part of the same namespace. It might be worth mentioning that in the
> > unregister_netdevice_many() function comments.
> 
> No it does not.  For the route cache flush we have already done the delayed
> invalidate per namespace.  So we only need to walk the route cache once and
> simply remove the entries that have been invalidated.
> 

Right ! I thought that we need to do the cache cleaning per namespace, now my 
patch looks really stupid :) 

