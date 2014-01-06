From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH v2 5/5] alx: add stats to ethtool
Date: Mon, 6 Jan 2014 11:57:42 +0100
Message-ID: <20140106105742.GA30142@kria>
References: <1388854031-24142-1-git-send-email-sd@queasysnail.net>
 <1388854031-24142-6-git-send-email-sd@queasysnail.net>
 <1388998990.5891.0.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, bhutchings@solarflare.com,
	netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpfb2-g21.free.fr ([212.27.42.10]:50116 "EHLO
	smtpfb2-g21.free.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752082AbaAFK6R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 05:58:17 -0500
Received: from smtp5-g21.free.fr (smtp5-g21.free.fr [212.27.42.5])
	by smtpfb2-g21.free.fr (Postfix) with ESMTP id BB682D19B59
	for <netdev@vger.kernel.org>; Mon,  6 Jan 2014 11:58:13 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <1388998990.5891.0.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[2014-01-06, 10:03:10] Johannes Berg wrote:
> On Sat, 2014-01-04 at 17:47 +0100, Sabrina Dubroca wrote:
> 
> > +	__alx_update_hw_stats(hw);
> > +	BUILD_BUG_ON(sizeof(hw->stats) - offsetof(struct alx_hw_stats, rx_ok) <
> > +		     ALX_NUM_STATS * sizeof(u64));
> 
> I think you should make that != instead of <, otherwise you won't catch
> all possible differences.

With a !=, BUILD_BUG_ON is triggered if a new field is added at the
end of the structure. But adding a field doesn't break the code,
though I'm not sure allowing this is useful. The offsetof (and the
source in memcpy) also allows to add new fields at the beginning.

And the way alx_update_hw_stats is written already includes a kind of
check that all fields are present.

-- 
Sabrina
