From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] xen-netfront: pull on receive skb may need to
 happen earlier
Date: Wed, 17 Jul 2013 12:52:05 -0700 (PDT)
Message-ID: <20130717.125205.635721424198600555.davem@davemloft.net>
References: <1373970815.4663.45.camel@kazak.uk.xensource.com>
	<51E65F5102000078000E57ED@nat28.tlf.novell.com>
	<1374049584.4663.64.camel@kazak.uk.xensource.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: JBeulich@suse.com, wei.liu2@citrix.com, g.w.kant@hunenet.nl,
	xen-devel@lists.xenproject.org, netdev@vger.kernel.org,
	stable@vger.kernel.org
To: Ian.Campbell@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52900 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757177Ab3GQTwH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jul 2013 15:52:07 -0400
In-Reply-To: <1374049584.4663.64.camel@kazak.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Campbell <Ian.Campbell@citrix.com>
Date: Wed, 17 Jul 2013 09:26:24 +0100

> On Wed, 2013-07-17 at 08:09 +0100, Jan Beulich wrote:
>> Due to commit 3683243b ("xen-netfront: use __pskb_pull_tail to ensure
>> linear area is big enough on RX") xennet_fill_frags() may end up
>> filling MAX_SKB_FRAGS + 1 fragments in a receive skb, and only reduce
>> the fragment count subsequently via __pskb_pull_tail(). That's a
>> result of xennet_get_responses() allowing a maximum of one more slot to
>> be consumed (and intermediately transformed into a fragment) if the
>> head slot has a size less than or equal to RX_COPY_THRESHOLD.
>> 
>> Hence we need to adjust xennet_fill_frags() to pull earlier if we
>> reached the maximum fragment count - due to the described behavior of
>> xennet_get_responses() this guarantees that at least the first fragment
>> will get completely consumed, and hence the fragment count reduced.
>> 
>> In order to not needlessly call __pskb_pull_tail() twice, make the
>> original call conditional upon the pull target not having been reached
>> yet, and defer the newly added one as much as possible (an alternative
>> would have been to always call the function right before the call to
>> xennet_fill_frags(), but that would imply more frequent cases of
>> needing to call it twice).
>> 
>> Signed-off-by: Jan Beulich <jbeulich@suse.com>
>> Acked-by: Wei Liu <wei.liu2@citrix.com>
> 
> Acked-by: Ian Campbell <ian.campbell@citrix.com>

Applied.
