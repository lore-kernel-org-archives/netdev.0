From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Fri, 11 May 2007 15:53:52 +0400
Message-ID: <20070511115352.GA6508@2ka.mipt.ru>
References: <20070511093202.GB24695@2ka.mipt.ru> <OF6C27DF4E.9060BDB4-ON652572D8.0035C627-652572D8.00363827@in.ibm.com> <20070511095602.GA5762@2ka.mipt.ru> <1178883002.4093.26.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>,
	Ian McDonald <ian.mcdonald@jandi.co.nz>,
	netdev@vger.kernel.org, Rick Jones <rick.jones2@hp.com>,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:59770 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756428AbXEKL5i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 May 2007 07:57:38 -0400
Content-Disposition: inline
In-Reply-To: <1178883002.4093.26.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 11, 2007 at 07:30:02AM -0400, jamal (hadi@cyberus.ca) wrote:
> > I meant no locks during processing of the packets (pci read/write, dma
> > setup and so on), of course it is needed to dequeue a packet, but only
> > for that operation.
> 
> I dont think you can avoid the lock Evgeniy. You need to protect against
> the tx ring having some other things happening to it from the napi poll
> or netdev interupts (most of the drivers touch the tx ring on the napi
> poll).

As I said there might be another lock, if interrupt handler is shared,
or registers are accessed, but it is privite driver's business, which
has nothing in common with stack itself. Stack just queues an skb,
which, after detached from the tx queue by driver, just does not exist
for stack anymore. It can be dequeed with rcu protection even.

> cheers,
> jamal

-- 
	Evgeniy Polyakov
