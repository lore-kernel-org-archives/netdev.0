From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gre: strict physical device binding
Date: Wed, 21 Jan 2009 13:54:52 -0800 (PST)
Message-ID: <20090121.135452.57299499.davem@davemloft.net>
References: <1232362205-10572-1-git-send-email-timo.teras@iki.fi>
	<20090119.172224.251874271.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56925
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752736AbZAUVyv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2009 16:54:51 -0500
In-Reply-To: <20090119.172224.251874271.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Mon, 19 Jan 2009 17:22:24 -0800 (PST)

> From: Timo Teras <timo.teras@iki.fi>
> Date: Mon, 19 Jan 2009 12:50:05 +0200
> 
> > Check the device on receive path and allow otherwise identical devices
> > as long as the physical device differs.
> > 
> > This is useful for NBMA tunnels, where you want to use different gre IP
> > for each public IP available via different physical devices.
> > 
> > Signed-off-by: Timo Teras <timo.teras@iki.fi>
> 
> Seems reasonable, applied.
> 
> Thanks Timo.

BTW, isn't it much more efficient to implement this priority scoring
using a simple integer instead of this big honking 4 entry array of
pointers on the stack (one entry of which isn't even _used_)?

Something like:

	int score = 4;

	...
	for_each_hash_chain() {
		if (!match)
			continue;
		if (exact_match)
			return this_entry;
		this_score = 0;
		if (condition1)
			this_score |= 2;
		if (condition2)
			this_score |= 1;
		if (this_score < score) {
			score = this_score;
			cand = this_entry;
		}
	}
	...
	return cand;
