From: Patrick McHardy <kaber@trash.net>
Subject: Re: [XFRM]: Fix leak of expired xfrm_states
Date: Mon, 26 Nov 2007 16:51:42 +0100
Message-ID: <474AEB8E.9040903@trash.net>
References: <474AE0B7.5010709@trash.net> <20071126154625.GI28022@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59947 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750696AbXKZPwe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2007 10:52:34 -0500
In-Reply-To: <20071126154625.GI28022@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Mon, Nov 26, 2007 at 04:05:27PM +0100, Patrick McHardy wrote:
>> This patch fixes a xfrm_state leak, which appears to be a
>> regression from the reference count simplifications.
> 
> I was going to say this was a good find :)
> 
> But digging deeper it seems that it might not be a bug after
> all.  Even though the ref count on x may now drop to zero, it
> won't be freed until del_timer_sync returns which should be
> sufficient, no?


It actually won't get freed at all currently since nothing is
calling __xfrm_state_destroy(). __xfrm_state_delete() uses
__xfrm_state_put(), which only decrements the refcount, but
doesn't perform destruction.

This is visible when looking at the xfrm[46]_mode_{tunnel,transport}
module reference counts, they climb higher and higher over time.
