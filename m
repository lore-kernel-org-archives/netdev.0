From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP and reordering
Date: Wed, 28 Nov 2012 09:16:36 -0800
Message-ID: <1354122996.14302.427.camel@edumazet-glaptop>
References: <20121127.210611.1127622873924794001.davem@davemloft.net>
	 <1354089566.21562.20.camel@shinybook.infradead.org>
	 <CAGK4HS8=NfcyvcNjC3h1wEjgQFCYoNeuWXj8n5Ruukeg+6j=SQ@mail.gmail.com>
	 <1354093703.21562.23.camel@shinybook.infradead.org>
	 <1354100552.14302.78.camel@edumazet-glaptop>
	 <1354103355.21562.46.camel@shinybook.infradead.org>
	 <1354105619.14302.89.camel@edumazet-glaptop>
	 <1354106362.21562.51.camel@shinybook.infradead.org>
	 <1354107140.14302.140.camel@edumazet-glaptop>
	 <1354117635.21562.63.camel@shinybook.infradead.org>
	 <20121128161930.GB19042@kvack.org>
	 <1354120887.21562.87.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Benjamin LaHaise <bcrl@kvack.org>,
	Vijay Subramanian <subramanian.vijay@gmail.com>,
	David Miller <davem@davemloft.net>, saku@ytti.fi,
	rick.jones2@hp.com, netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f174.google.com ([209.85.210.174]:46930 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752392Ab2K1RQj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 12:16:39 -0500
Received: by mail-ia0-f174.google.com with SMTP id y25so10060914iay.19
        for <netdev@vger.kernel.org>; Wed, 28 Nov 2012 09:16:39 -0800 (PST)
In-Reply-To: <1354120887.21562.87.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-11-28 at 16:41 +0000, David Woodhouse wrote:

> Another fun issue with tunnelling protocols and BQL... packets tend to
> *grow* as they get encapsulated. So you might end up calling
> netdev_sent_queue() with a given size, then netdev_completed_queue()
> with a bigger packet later...

Its the driver responsibility to maintain the coherent 'bytes' value for
each transmitted/completed packet.

If a driver calls an external entity, it cannot possibly use BQL, unless
doing an approximation (bytes becomes a fixed value)

BQL was really something to control/limit queueing on ethernet links,
not for stacked devices, as stacked devices normally have no queue.
