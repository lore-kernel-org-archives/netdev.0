From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [RFC PATCH v2] net: fold dev_disable_lro() into
 netdev_fix_features()
Date: Thu, 12 May 2011 09:57:49 -0700
Message-ID: <20110512095749.016610a1@nehalam>
References: <20110507114803.0D80A13A6B@rere.qmqm.pl>
	<20110512160640.2A0B713A6B@rere.qmqm.pl>
	<1305217747.5214.17.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>,
	bridge@lists.linux-foundation.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:43784 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757426Ab1ELQ7P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 12:59:15 -0400
In-Reply-To: <1305217747.5214.17.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 12 May 2011 17:29:07 +0100
Ben Hutchings <bhutchings@solarflare.com> wrote:

> >  	dev->priv_flags |= IFF_BRIDGE_PORT;
> >  
> > -	dev_disable_lro(dev);
> > -
> >  	list_add_rcu(&p->list, &br->port_list);
> >  
> > -	netdev_update_features(br->dev);
> > +	netdev_change_features(dev);
> >  
> >  	spin_lock_bh(&br->lock);
> >  	changed_addr = br_stp_recalculate_bridge_id(br);  
> 
> Why netdev_change_features() here?  I thought that was primarily for use
> when vlan_features may have been changed.

Setting IFF_BRIDGE_PORT in priv_flags causes change_features
to disable LRO.

-- 
