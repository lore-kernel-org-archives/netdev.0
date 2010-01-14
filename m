From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] sky2: safer transmit ring cleaning (v4)
Date: Thu, 14 Jan 2010 09:52:54 -0800
Message-ID: <20100114095254.5cf7faa0@nehalam>
References: <20100112085633.GB6628@ff.dom.local>
	<20100112.014218.112731835.davem@davemloft.net>
	<20100112.025620.210305029.davem@davemloft.net>
	<20100112081513.0175d579@nehalam>
	<4B4CC0E3.5050106@majjas.com>
	<4B4CC29E.4020703@majjas.com>
	<4B4CDC28.2050508@majjas.com>
	<20100112201012.21894fd3@nehalam>
	<4B4DEEF9.7020806@majjas.com>
	<20100113194148.139091a3@nehalam>
	<20100114101445.GA7210@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Michael Breuer <mbreuer@majjas.com>,
	David Miller <davem@davemloft.net>, mikem@ring3k.org,
	flyboy@gmail.com, rjw@sisk.pl, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50873 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757345Ab0ANRxK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jan 2010 12:53:10 -0500
In-Reply-To: <20100114101445.GA7210@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 14 Jan 2010 10:14:45 +0000
Jarek Poplawski <jarkao2@gmail.com> wrote:

> This makes it safe, but it still resembles the "short term fix"
> according do David's opinion.
> 
> This change seems to affect dev->stats too. Since they are not
> updated in sky2_tx_clean(). Btw, I hope "&" is some optimization
> because it's less readable than "&&".

Stats don't matter for packets flushed during device reset.

The & is because in the most common case device is up,
and we don't want the additional conditional branch.
