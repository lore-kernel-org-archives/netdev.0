From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: pre-fetching skb for delayed send
Date: Fri, 6 Jul 2012 19:52:58 -0400
Message-ID: <20120706235258.GD19462@kvack.org>
References: <4FF77070.7040705@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:37784 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750698Ab2GFXw7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2012 19:52:59 -0400
Content-Disposition: inline
In-Reply-To: <4FF77070.7040705@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 06, 2012 at 04:10:40PM -0700, Ben Greear wrote:
> So, is there an easy way to pre-fetch an skb and it's related pages?

One trick would be to store the pointers to the skbs in an array rather than 
relying on a list of skbs.  That would enable you to issue prefetches for 
multiple skbs from a single cache line of the array, rather than relying 
upon the slow chasing of pointers guaranteed to cache miss in a list.

		-ben
-- 
"Thought is the essence of where you are now."
