From: Jeba Anandhan <jeba.anandhan@vaioni.com>
Subject: Re: unregister_netdev() deadlock
Date: Wed, 27 Feb 2008 17:05:11 +0000
Message-ID: <1204131913.3543.7.camel@vglwks010.vgl2.office.vaioni.com>
References: <1204127094.11318.0.camel@vglwks010.vgl2.office.vaioni.com>
	 <20080227084624.163c762b@extreme>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, matthew.hattersley@vaioni.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vglsrv002.office.vaioni.com ([84.19.35.12]:58884 "EHLO
	vglsrv02.vgl2.office.vaioni.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752706AbYB0RHW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2008 12:07:22 -0500
In-Reply-To: <20080227084624.163c762b@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-02-27 at 08:46 -0800, Stephen Hemminger wrote:
> On Wed, 27 Feb 2008 15:44:54 +0000
> Jeba Anandhan <jeba.anandhan@vaioni.com> wrote:
> 
> > Hi all,
> > I have doubts about unregister the netdevice.
> > 
> > Scenario
> > I have two netdevice entities. I wish to unregister one entity.
> > 
> > struct net_device *dev1;
> > struct net_device *dev2;
> > 
> > dev1->timer = XXX;
> > dev2->timer = YYY;
> > 
> > dev1->ioctl() {
> > 
> > ...
> > case delete_other:
> >             unregister_netdev(dev2);
> >             free_netdev(dev2);
> >             return 0;
> > ...
> > }
> > 
> > The dev2->refcnt is not zero in this case. unregister_netdev(dev2) cause
> > deadlock. Could you tell me why it happens?.
> > 
> > 
> > It works smoothly when we call the unregister_netdev(dev2) from
> > cleanup_module(). dev2->refcnt is not zero in this case.  Still it is
> > able to unregister.
> > 
> > 
> > Thanks
> > Jeba
> > 
> 
> You need to properly manage device refcounts (or delete both).
> Also since dev1->ioctl is called with RTNL you can't:
>     use unregister_netdev() recursive locking (use unregister_netdevice)
>     or  call free_netdev because of netdevice could still be in use (use dev->destructor instead).

*) Is there any chance of deadlock if i try to unregister_netdev() on
the fly using syscall?
*) is dev->refcnt altered by only dev_hold or dev_put?. what are the
general cases where the dev->refcnt is altered?

Thanks
Jeba
