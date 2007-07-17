From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: [patch 37/44] xen: add virtual network device driver
Date: Tue, 17 Jul 2007 07:28:50 -0700
Message-ID: <469CD222.1030202@goop.org>
References: <20070716231536.937393000@xensource.com>	<20070716232916.472694000@xensource.com> <20070717094511.795beb69@oldman>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jeremy Fitzhardinge <jeremy@xensource.com>,
	Linus Torvalds <torvalds@linux-foundation.com>,
	Andi Kleen <ak@suse.de>,
	Andrew Morton <akpm@linux-foundation.com>,
	lkml <linux-kernel@vger.kernel.org>,
	Xen-devel <xen-devel@lists.xensource.com>,
	Chris Wright <chrisw@sous-sol.org>,
	Ian Pratt <ian.pratt@xensource.com>,
	Christian Limpach <Christian.Limpach@cl.cam.ac.uk>,
	Jeff Garzik <jeff@garzik.org>,
	Christoph Hellwig <hch@infradead.org>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Keir Fraser <Keir.Fraser@cl.cam.ac.uk>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw.goop.org ([64.81.55.164]:52951 "EHLO mail.goop.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755070AbXGQO3p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jul 2007 10:29:45 -0400
In-Reply-To: <20070717094511.795beb69@oldman>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
>> +struct netfront_info {
>> +	struct list_head list;
>> +	struct net_device *netdev;
>> +
>> +	struct net_device_stats stats;
>>     
>
> There is now a net_device_stats element inside net_device on
> 2.6.21 or later.
>   

Ah, OK.  Should I just do a s/stats/netdev->stats/?  Is there a generic
get_stats routine as well?

>> +
>> +	struct xen_netif_tx_front_ring tx;
>> +	struct xen_netif_rx_front_ring rx;
>> +
>> +	spinlock_t   tx_lock;
>> +	spinlock_t   rx_lock;
>>     
>
> It might be a performance advantage to reorder/align these
> structure elements to put transmit hot elements together, and
> put tx and rx on different cache lines?
>   

Oh, right.  I'd been meaning to look at that layout more closely.

Thanks,
    J
