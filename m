From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8169: Don't update statistics counters when interface
 is down
Date: Fri, 06 Feb 2009 01:33:10 -0800 (PST)
Message-ID: <20090206.013310.68845344.davem@davemloft.net>
References: <20090203214641.GA354@electric-eye.fr.zoreil.com>
	<1233743518-8271-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org
To: ivecera@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59587
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758221AbZBFJdO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2009 04:33:14 -0500
In-Reply-To: <1233743518-8271-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ivan Vecera <ivecera@redhat.com>
Date: Wed,  4 Feb 2009 11:31:58 +0100

> Francois Romieu wrote:
> > 
> > int dev_close(struct net_device *dev)
> > {
> > [...]
> > 	clear_bit(__LINK_STATE_START, &dev->state);
> >         -> netif_running is not true anymore
> > [...]
> > 	if (ops->ndo_stop)
> > 		ops->ndo_stop(dev);
> > 
> > -> Calling rtl8169_update_counters in rtl8169_close looks like a no-op.
> Yes that's true, it's better to test whether the receiver is enabled or not.
> 
> > 
> > Aside from that, I do not understand from the description the need for
> > the "while (wait--)" loop.
> To avoid potential endless loop, only for sure.
> 
> > 
> > Aside from the aside, the diff can probably be shorter if a local "counters"
> > variable is kept in the ethtool function (nit).
> I wanted to update counters also when the interface is going down and this needs
> to store the counters in device struct. These will be returned when the
> interface is down (resp. the receiver is disabled).
> 
> Updated patch with correct test condition:

Francois, any objections?
