From: Eldon Koyle <esk-netdev@esk.cs.usu.edu>
Subject: Re: multiqueue, skb_get_queue_mapping() and netdev_get_tx_queue()
Date: Thu, 15 Jul 2010 10:22:02 -0600
Message-ID: <20100715162201.GB32397@esk.cs.usu.edu>
References: <20100714231352.GA32397@esk.cs.usu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from esk.cs.usu.edu ([129.123.28.15]:50086 "EHLO esk.cs.usu.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933679Ab0GOQWE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jul 2010 12:22:04 -0400
Received: from esk by esk.cs.usu.edu with local (Exim 4.69)
	(envelope-from <esk@esk.cs.usu.edu>)
	id 1OZRCE-00019h-13
	for netdev@vger.kernel.org; Thu, 15 Jul 2010 10:22:02 -0600
Content-Disposition: inline
In-Reply-To: <20100714231352.GA32397@esk.cs.usu.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On  Jul 14 17:13-0600, Eldon Koyle wrote:
> It looks like there is a potential for an out of bounds index anywhere
> skb_get_queue_mapping(skb) (which just returns skb->queue_mapping) is
> used to get an index for netdev_get_tx_queue() (and probably other
> places) on a device with multiple rx/tx queues.

Looking more closely, it looks like skb->queue_mapping is treated
differently between rx and tx.  In net/core/dev.c in dev_pick_tx, it
uses skb_tx_hash to get the tx queue it should use and then does:
	skb_set_queue_mapping(skb, queue_index);
	return netdev_get_tx_queue(dev, queue_index);

Sorry for the noise.

-- 
Eldon Koyle
-- 
He who renders warfare fatal to all engaged in it will be the greatest
benefactor the world has yet known.
		-- Sir Richard Burton
