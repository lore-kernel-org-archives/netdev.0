From: Brandon Philips <brandon@ifup.org>
Subject: Re: [patch 0/5][RFC] Update network drivers to use devres
Date: Fri, 3 Aug 2007 11:23:35 -0700
Message-ID: <20070803182335.GA4294@ifup.org>
References: <20070802224206.GB5181@ifup.org> <20070803095857.5fb3f368@oldman.hamilton.local> <20070803102645.GO13674@htj.dyndns.org> <20070803120745.2d89c221@oldman.hamilton.local> <46B31270.7090503@gmail.com> <20070803144409.3f95c91d@oldman.hamilton.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tejun Heo <htejun@gmail.com>, netdev@vger.kernel.org,
	teheo@suse.de, bphilips@suse.de
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.189]:9765 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751773AbXHCSXl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Aug 2007 14:23:41 -0400
Received: by rv-out-0910.google.com with SMTP id k20so735162rvb
        for <netdev@vger.kernel.org>; Fri, 03 Aug 2007 11:23:41 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20070803144409.3f95c91d@oldman.hamilton.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 14:44 Fri 03 Aug 2007, Stephen Hemminger wrote:
> On Fri, 03 Aug 2007 20:33:04 +0900 Tejun Heo <htejun@gmail.com> wrote:
> > >> Devres makes low level drivers simpler, easier to get right and
> > >> maintain.  Writing new drivers becomes easier too.  So, why not?
> > >>
> > >>> Network devices seem to work fine thanks, and the resource requirements
> > >>> are different. If ain't broke, don't fix it.
> > >> Care to enlighten me on how the resource requirments are different
> > >> from ATA drivers?
> > > 
> > > I was thinking of the hot remove (no mod ref counts) and lingering
> > > /sys open issues.  ATA drivers use ref counts.
> > 
> > I guess the hot removing is done by severing netdev from the actual
> > device, right?  I don't see how that affects usage of devres on network
> > drivers.  Am I missing something?
> 
> The issue is that device may be removed at any time. So you can't rely
> on module ref counts to save you. And netdevice structure must still
> linger after module is removed, till dev ref count goes to zero.

These patches allow the net_device to linger.  The code calls
free_netdev on device removal just as before.

This is how the net_device is handled on device removal by these
patches:

+static void devm_free_netdev(struct device *gendev, void *res)
+{
+       struct net_device *dev = dev_get_drvdata(gendev);
+       free_netdev(dev);
+}

> > On a separate note, can you explain lingering /sys open issue to me a
> > bit?  With recent sysfs changes, sysfs nodes are disconnected
> > immediately on deletion.  Would that make any difference to netdevs?
> 
> Examples are in Documentation/networking/netdevices.txt

Isn't this the same problem as above?  The net_device structure must
stay around if there are still references to it and it does.  

Or am I missing something?

Thanks,

	Brandon
