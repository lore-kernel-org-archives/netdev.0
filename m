From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH v3 net-next 2/2] net: deprecate eth_change_mtu, remove
 usage
Date: Mon, 17 Oct 2016 18:20:49 +0100
Message-ID: <20161017182049.4be802d1@jkicinski-Precision-T1700>
References: <20161017172006.4d549daa@jkicinski-Precision-T1700>
        <20161017.124954.360760874377344385.davem@davemloft.net>
        <20161017180027.4936fa15@jkicinski-Precision-T1700>
        <20161017.131513.135103913948374087.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jarod@redhat.com, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.11]:36254 "EHLO mx4.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1030340AbcJQRUz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 17 Oct 2016 13:20:55 -0400
In-Reply-To: <20161017.131513.135103913948374087.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 17 Oct 2016 13:15:13 -0400 (EDT), David Miller wrote:
> From: Jakub Kicinski <kubakici@wp.pl>
> Date: Mon, 17 Oct 2016 18:00:27 +0100
> 
> > On Mon, 17 Oct 2016 12:49:54 -0400 (EDT), David Miller wrote:  
> >> From: Jakub Kicinski <kubakici@wp.pl>
> >> Date: Mon, 17 Oct 2016 17:20:06 +0100
> >>   
> >> > Please correct me if I'm wrong but it seems like we are now limiting
> >> > _all_ ethernet drivers to ETH_DATA_LEN in net-next.    
> >> 
> >> No, because the driver can increase the netdev->max_mtu value as needed.  
> > 
> > But since almost no driver is doing that, yet, right now in net-next
> > jumbo frames are not possible, no?  I thought the idea was the leave
> > the value at 0 so drivers can opt-in as needed but since setup_ether()
> > is initializing to 1500 now all ethernet driver get a default of
> > limiting to 1500.
> > 
> > IOW this patch made checks which were done only in eth_change_mtu()
> > mandatory for all drivers.  
> 
> The conversions he made were in cases where the driver's method was doing
> exactly the same thing eth_change_mtu() does not.
> 
> He strictly worked to keep the behavior identical compared to before his
> changes, please read his patches carefully.

Hm.  I must be missing something really obvious.  I just booted
net-next an hour ago and couldn't set MTU to anything larger than 1500
on either nfp or igb.  As far as I can read the code it will set the
max_mtu to 1500 in setup_ether() but none of the jumbo-capable drivers
had been touched by Jarod so far...
