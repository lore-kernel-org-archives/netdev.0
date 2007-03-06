From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH]: Dynamically sized routing cache hash table.
Date: Tue, 06 Mar 2007 01:17:06 -0800 (PST)
Message-ID: <20070306.011706.26279529.davem@davemloft.net>
References: <20070305.202632.74752497.davem@davemloft.net>
	<20070306091112.GA12365@wotan.suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dada1@cosmosbay.com,
	robert.olsson@its.uu.se, paulmck@us.ibm.com
To: npiggin@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45139
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933174AbXCFJRK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 04:17:10 -0500
In-Reply-To: <20070306091112.GA12365@wotan.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nick Piggin <npiggin@suse.de>
Date: Tue, 6 Mar 2007 10:11:12 +0100

> @@ -1449,6 +1472,12 @@ static struct dst_entry *ipv4_negative_a
>  					  "%u.%u.%u.%u/%02x dropped\n",
>  				NIPQUAD(rt->rt_dst), rt->fl.fl4_tos);
>  #endif
> +			/* XXX:
> +			 * What if rt does not exist in rt_hash, but is in
> +			 * old_rt_hash? Don't we have to also check there?
> +			 * Similar questions for a couple of other places that
> +			 * look at rt_hash, but not old_rt_hash.
> +			 */
>  			rt_del(h, hash, rt);
>  			ret = NULL;
>  		}

For the cases like ip_rt_redirect() I made the decision that we'll
just not add the complexity of having to look in the old_rt_hash
table.

In these kinds of cases it's OK to miss events, they will just happen
again.

It's one of the nice things about the routing cache, if you lose
information it's OK because we'll just cook up a new entry from
the persistent backing store that is the real routing tables.
And for events like redirects, if we miss it, we'll just send the
packet to the wrong next-hop again and receive another redirect
message which we'll (hopefully) propagate to a routine cache
entry.

Thanks for your feedback patch Nick, I'll process it tomorrow
hopefully after getting some sleep.
