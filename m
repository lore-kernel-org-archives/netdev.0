From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH 6/6] r8169: print errors when dma mapping fail
Date: Fri, 15 Oct 2010 17:59:56 +0200
Message-ID: <20101015155956.GA4286@redhat.com>
References: <1287144922-3297-1-git-send-email-sgruszka@redhat.com>
 <1287144922-3297-6-git-send-email-sgruszka@redhat.com>
 <20101015145201.GB4417@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Denis Kirjanov <kirjanov@gmail.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23654 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755119Ab0JOP5e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Oct 2010 11:57:34 -0400
Content-Disposition: inline
In-Reply-To: <20101015145201.GB4417@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 15, 2010 at 04:52:01PM +0200, Francois Romieu wrote:
> Stanislaw Gruszka <sgruszka@redhat.com> :
> > Print errors because dma mapping failures can cause device to stop
> > working and will need user intervention to recover.
> 
> I am hesitating (overengineered ? bloaty ? not the right place ?).

As someone who seen lot's of bug reports like "my network device stops
working, nothing in dmesg", or like "my network device stops working,
there is NETDEV WATCHDOG: eth0 (r8169): transmit queue 0 timed out in
dmesg" (what is nothing but useful information), I do no think this is
overengineered or bloaty. I could agree for "not the right place", but
even if the error would be reported by upper layers, exact reason of
the problem will be unknown. Regarding lower layers, I don't think iommu
or other dma code print warning with calltrace in case of failure.

> The Tx stats are kept up-to-date : Tx failure will go along a Tx drop
> stat increase.

In current implementation, I stop tx queue on dma errors, if that
happens the queue can never be started again. I will probably change
that as you suggest not returning NETDEV_TX_BUSY, stopping the queue
is also wrong. But I would like to keep this error messages, perhaps
after adding net_ratelimit() check.
 
> Regarding a mapping failure in the Rx path, either it will behave as
> an allocation failure at open / resume time -

Still it's worth to know exact reason of failure.

> and I have no idea how
> the user will recover - or it will happen during a Rx ring refill.

ifconfig eth0 down/up or reloading module

Stanislaw
