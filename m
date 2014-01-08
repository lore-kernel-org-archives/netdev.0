From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] net: xfrm6: silence sparse warning
Date: Wed, 8 Jan 2014 20:46:10 +0000
Message-ID: <1389213970.1644.39.camel@bwh-desktop.uk.level5networks.com>
References: <1389149801-29011-1-git-send-email-ying.xue@windriver.com>
	 <20140107.224357.1577838150943921013.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <ying.xue@windriver.com>, <steffen.klassert@secunet.com>,
	<dborkman@redhat.com>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17787 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756559AbaAHUqP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 15:46:15 -0500
In-Reply-To: <20140107.224357.1577838150943921013.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-01-07 at 22:43 -0500, David Miller wrote:
> From: Ying Xue <ying.xue@windriver.com>
> Date: Wed, 8 Jan 2014 10:56:40 +0800
> 
> > Fix below sparse warning:
> > 
> > net/ipv6/xfrm6_state.c:66:26: error: cannot size expression
>  ...
> > -	memset(count, 0, sizeof(count));
> > +	memset(count, 0, sizeof(int) * maxclass);
> 
> I think the fix belongs in sparse, making it respect these two expressions
> as equivalent.

It looks like sparse just doesn't support sizeof(VLA), although this is
valid C.

(It makes the same complaint about some places in sfc where we've used
min_t() in array dimensions, as that makes them VLAs even though the
size can actually be determined at compile time.)

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
