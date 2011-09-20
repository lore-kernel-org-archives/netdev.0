From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next 11/13] igb: Make Tx budget for NAPI user adjustable
Date: Tue, 20 Sep 2011 01:10:01 +0100
Message-ID: <1316477404.14749.256.camel@deadeye>
References: <19fca01e-5827-4e28-b12c-2b65cca96878@tahiti.vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: jeffrey t kirsher <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	gospo@redhat.com, Alexander H Duyck <alexander.h.duyck@intel.com>
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:5310 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751974Ab1ITAKM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2011 20:10:12 -0400
In-Reply-To: <19fca01e-5827-4e28-b12c-2b65cca96878@tahiti.vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-09-19 at 16:42 -0700, Stephen Hemminger wrote:
> I would like to see a general solution to allow configuring
> napi weight. The Rx weight isn't easily configurable either.

Indeed.

> Probably needs to be through ethtool callback since actual value range
> and dev -> napi relationship is device specific.

The maximum meaningful value is device specific but I'm not sure that
really matters.

And as David said it's really a many-to-one mapping of queue -> NAPI.
At netconf we talked about having 'irq' as an attribute of each queue
but maybe we should expose NAPI contexts through sysfs and make queues
refer to them instead.  NAPI contexts would be named (in the same way as
the corresponding IRQ handlers) and have irq, weight, etc.

(Still short of time to work on this myself, alas.)

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
