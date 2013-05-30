From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [Patch net-next] net: clean up skb headers code
Date: Thu, 30 May 2013 15:11:50 +0100
Message-ID: <1369923110.3469.449.camel@deadeye.wl.decadent.org.uk>
References: <1369807740-12324-1-git-send-email-amwang@redhat.com>
	 <20130528.233647.1209227470109213894.davem@davemloft.net>
	 <1369856073.1971.2.camel@bwh-desktop.uk.level5networks.com>
	 <20130530.034021.851099674189749250.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <amwang@redhat.com>, <netdev@vger.kernel.org>, <horms@verge.net.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:34256 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755087Ab3E3OLy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 10:11:54 -0400
In-Reply-To: <20130530.034021.851099674189749250.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-05-30 at 03:40 -0700, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Wed, 29 May 2013 20:34:33 +0100
> 
> > On Tue, 2013-05-28 at 23:36 -0700, David Miller wrote:
> >> From: Cong Wang <amwang@redhat.com>
> >> Date: Wed, 29 May 2013 14:09:00 +0800
> >> 
> >> > commit 1a37e412a0225fcba5587 (net: Use 16bits for *_headers
> >> > fields of struct skbuff) converts skb->*_header to u16,
> >> > therefore 1) we could just use 0xFFFFF instead of (__u16) ~0U
> >> > 2) some #if NET_SKBUFF_DATA_USES_OFFSET is useless now.
> >> > 
> >> > 
> >> > Cc: David S. Miller <davem@davemloft.net>
> >> > Cc: Simon Horman <horms@verge.net.au>
> >> > Signed-off-by: Cong Wang <amwang@redhat.com>
> >> 
> >> I want to use something that will either break the build or
> >> automatically work if the type changes again.
> >> 
> >> So something like "X = (typeof(X)) ~0U;".
> > 
> > I think you mean ~(typeof(X))0.
> 
> Take a look at what that does for ~(u8)0.
> 
> We had a bug fix in this are recently in ieee802154 if I remember
> correctly.

It's fine if you assign the result to X.  The second cast is needed if
you need the temporary value to have the type of X, but that's not
needed here.  (Of course it may be promoted as soon as you do anything
other than assign to X...)

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
