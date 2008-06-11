From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: 2.6.25rc7 lockdep trace
Date: Wed, 11 Jun 2008 07:08:47 +0000
Message-ID: <20080611070847.GA4171@ff.dom.local>
References: <20080610.224023.116817726.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johannes@sipsolutions.net, davej@codemonkey.org.uk,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:5165 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752386AbYFKHEl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2008 03:04:41 -0400
Received: by fg-out-1718.google.com with SMTP id 19so2028834fgg.17
        for <netdev@vger.kernel.org>; Wed, 11 Jun 2008 00:04:39 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080610.224023.116817726.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11-06-2008 07:40, David Miller wrote:
...
> Ok, I did an audit of all the drivers under drivers/net that invoke
> flush_scheduled_work().  Here is my audit analysis and the patch I
> came up with.  The only deadlock'y case I couldn't fix right now is
> the cassini driver, see below for details and the patch:
> 
> 8139too: Calls flush_scheduled_work() in device remove method, OK.

I have some doubt here: this rtl8139_thred() work function seems to
rearm if netif_running(). Is it guaranteed a dev is down while
running this flush_scheduled_work()?

Regards,
Jarek P.
