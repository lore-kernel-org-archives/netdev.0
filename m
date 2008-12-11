From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] netpoll: fix race on poll_list resulting in garbage entry
Date: Thu, 11 Dec 2008 09:29:00 -0500
Message-ID: <20081211142900.GA10558@hmsendeavour.rdu.redhat.com>
References: <20081209210644.GC3785@hmsreliant.think-freely.org> <20081211130728.GB5910@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:52587 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755569AbYLKObS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2008 09:31:18 -0500
Content-Disposition: inline
In-Reply-To: <20081211130728.GB5910@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 11, 2008 at 01:07:28PM +0000, Jarek Poplawski wrote:
> On 09-12-2008 22:06, Neil Horman wrote:
> ...
> > When executing napi->poll from the netpoll_path, this bit will
> > be set. When a driver calls netif_rx_complete, if that bit is set, it will not
> > remove the napi_struct from the poll_list.  That work will be saved for the next
> > iteration of net_rx_action.
> 
> This could be not enough: some drivers, e.g. sky2, call napi_complete()
> directly.
> 
I agree, some drivers might circumvent this, but I would argue that the bug in
those cases is that the driver isn't using the right api entry point, and its
the driver that needs fixing in those cases.

I chose netif_rx_complete to make that test intentionally.  Since napi_complete
gets called with local irqs disabled, I wanted the napi path to avoid doing
that, so as to block the net_rx_action fast path for as small a time as
possible.

I think the number of drivers that circumvents the netif_rx_action call is both
small and (I think) not always needed.  They can probably be migrated to use
netif_rx_complete very easily.  I'll take a look into doing that.

Neil

> Regards,
> Jarek P.
> 

-- 
/***************************************************
 *Neil Horman
 *nhorman@tuxdriver.com
 *gpg keyid: 1024D / 0x92A74FA1
 *http://pgp.mit.edu
 ***************************************************/
