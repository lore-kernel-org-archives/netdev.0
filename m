From: David Miller <davem@davemloft.net>
Subject: Re: [v2 PATCH] net: Stop decapitating clones that have a head_frag
Date: Thu, 03 May 2012 01:39:00 -0400 (EDT)
Message-ID: <20120503.013900.1894092726730059556.davem@davemloft.net>
References: <20120503041842.8315.16138.stgit@gitlad.jf.intel.com>
	<1336019638.12425.16.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org,
	edumazet@google.com, jeffrey.t.kirsher@intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39917 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752286Ab2ECFjE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2012 01:39:04 -0400
In-Reply-To: <1336019638.12425.16.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 03 May 2012 06:33:58 +0200

> On Wed, 2012-05-02 at 21:18 -0700, Alexander Duyck wrote:
>> This change is meant ot prevent stealing the skb->head to use as a page in
>> the event that the skb->head was cloned.  This allows the other clones to
>> track each other via shinfo->dataref.
>> 
>> Without this we break down to two methods for tracking the reference count,
>> one being dataref, the other being the page count.  As a result it becomes
>> difficult to track how many references there are to skb->head.
>> 
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
...
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.

These tests of the form:

	head_frag || cloned

and

	head_frag && cloned

will probably crop up in other places.  Therefore we should probably
add a "skb_head_is_locked()" helper function to skbuff.h

Well, there are already two instances, which is candidate enough. :-)
