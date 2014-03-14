From: Jakub =?UTF-8?B?S2ljacWEc2tp?= <moorray3@wp.pl>
Subject: Re: [PATCH net-next 02/10] e1000e: add timeout for TX HW time
 stamping work
Date: Fri, 14 Mar 2014 19:02:42 +0100
Message-ID: <20140314190242.4bba2b42@north>
References: <1394818481-7652-1-git-send-email-kubakici@wp.pl>
	<1394818481-7652-3-git-send-email-kubakici@wp.pl>
	<1394819317.3253.3.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.9]:20482 "EHLO mx3.wp.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754461AbaCNSCp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Mar 2014 14:02:45 -0400
In-Reply-To: <1394819317.3253.3.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 14 Mar 2014 10:48:37 -0700, Joe Perches wrote:
> On Fri, 2014-03-14 at 18:34 +0100, Jakub Kicinski wrote:
> > Hardware may fail to report time stamp e.g.:
> >  - when hardware time stamping is not enabled
> >  - when time stamp is requested shortly after ifup
> 
> trivia:
> 
> > diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
> []
> > @@ -1155,6 +1155,12 @@ static void e1000e_tx_hwtstamp_work(struct work_struct *work)
> >  		skb_tstamp_tx(adapter->tx_hwtstamp_skb, &shhwtstamps);
> >  		dev_kfree_skb_any(adapter->tx_hwtstamp_skb);
> >  		adapter->tx_hwtstamp_skb = NULL;
> > +	} else if (time_after(jiffies, adapter->tx_hwtstamp_start
> > +			      + adapter->tx_timeout_factor * HZ)) {
> > +		dev_kfree_skb_any(adapter->tx_hwtstamp_skb);
> > +		adapter->tx_hwtstamp_skb = NULL;
> > +		adapter->tx_hwtstamp_timeouts++;
> > +		e_warn("clearing Tx timestamp hang");
> 
> Missing \n termination

I copied that line from ixgbe and assumed that the magic macro adds
termination...

I see that igb and i40e also lack the \n on similar messages. Can I fix
them all in a single follow-up patch?

Thanks for catching this.

	-- kuba
