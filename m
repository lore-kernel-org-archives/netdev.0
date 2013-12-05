From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net 0/3] be2net fixes
Date: Thu, 5 Dec 2013 15:58:45 +0000
Message-ID: <1386259125.1516.115.camel@bwh-desktop.uk.level5networks.com>
References: <7F44EA5110810A40B7DAFB605C41975D2C96274B@CMEXMB1.ad.emulex.com>
	 <20131205.003925.220601244226026270.davem@davemloft.net>
	 <7F44EA5110810A40B7DAFB605C41975D2C96279B@CMEXMB1.ad.emulex.com>
	 <20131205.012813.2201475304685818121.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <Somnath.Kotur@Emulex.Com>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:59601 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756808Ab3LEP6t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 10:58:49 -0500
In-Reply-To: <20131205.012813.2201475304685818121.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-12-05 at 01:28 -0500, David Miller wrote:
> From: Somnath Kotur <Somnath.Kotur@Emulex.Com>
> Date: Thu, 5 Dec 2013 06:24:10 +0000
> 
> >> This is absolutely not something an individual driver should decide to do,
> >> _EVERY_ driver has this issue.
> > 
> > OK, Understood, guess you want this to ideally be handled somewhere up in the stack/framework?
> 
> I think it's pointless to do at all.

It's not entirely pointless - if there is a lot of unwanted multicast
traffic the change to all-multicast can substantially increase CPU load
and the reason for this may not be obvious since there is no way to find
out the real state of the hardware filter (or even the real state of the
IFF_ALLMULTI flag).

The same may be true if an interface is automatically switched into
promiscuous mode, though switches can generally be assumed to filter
unicast traffic properly.

It seems like it would be useful to expose the real state of the
hardware filter to userland - just not through log messages.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
