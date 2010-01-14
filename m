From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] sky2: safer transmit ring cleaning (v4)
Date: Thu, 14 Jan 2010 11:16:36 +0000
Message-ID: <20100114111636.GB7210@ff.dom.local>
References: <20100112.014218.112731835.davem@davemloft.net> <20100112.025620.210305029.davem@davemloft.net> <20100112081513.0175d579@nehalam> <4B4CC0E3.5050106@majjas.com> <4B4CC29E.4020703@majjas.com> <4B4CDC28.2050508@majjas.com> <20100112201012.21894fd3@nehalam> <4B4DEEF9.7020806@majjas.com> <20100113194148.139091a3@nehalam> <20100114101445.GA7210@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Breuer <mbreuer@majjas.com>,
	David Miller <davem@davemloft.net>, mikem@ring3k.org,
	flyboy@gmail.com, rjw@sisk.pl, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f225.google.com ([209.85.220.225]:60676 "EHLO
	mail-fx0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751481Ab0ANLQl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jan 2010 06:16:41 -0500
Received: by fxm25 with SMTP id 25so355138fxm.21
        for <netdev@vger.kernel.org>; Thu, 14 Jan 2010 03:16:39 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20100114101445.GA7210@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 14, 2010 at 10:14:45AM +0000, Jarek Poplawski wrote:
> On Wed, Jan 13, 2010 at 07:41:48PM -0800, Stephen Hemminger wrote:
> > Subject: sky2: safer transmit cleanup
...
> > +	if (!(netif_running(dev) & netif_device_present(dev)))
> 
> This makes it safe, but it still resembles the "short term fix"
> according do David's opinion.

Hmm... Actually, it's not safe, but still safer again. It looks like
David was right (this time ;-). Since netif_device_present() isn't
protected by a lock here, this is still racy against napi, since the
flag can be set between the test and the wakeup. Btw, there is even no
barrier, and in your patch this dangerous distance is made much wider.

So, now I really ;-) agree with David: this needs a proper fix.
 
Jarek P.
