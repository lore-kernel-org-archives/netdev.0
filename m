From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH -next 3/3] tcp: use dctcp if enabled on the route to the
 initiator
Date: Sat, 29 Aug 2015 22:51:21 +0200
Message-ID: <55E21B49.4050204@iogearbox.net>
References: <1440763869-23067-1-git-send-email-fw@strlen.de>	<1440763869-23067-4-git-send-email-fw@strlen.de> <20150828.141858.298466824970321801.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:46703 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752252AbbH2Uv0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2015 16:51:26 -0400
In-Reply-To: <20150828.141858.298466824970321801.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/28/2015 11:18 PM, David Miller wrote:
...
> I don't know about this.
>
> You're adding a new user visible feature bit, but...
>
> The user can set it and silently the kernel will accept it, but this
> bit is ignored.
>
> Regardless of it's internal value, we never publish it to the user.
>
> This is just asking for trouble, and it's a bit sloppy if you ask me.
>
> I think you're going to need to hold this piece of state outside of
> the metric value, sorry.

Understood, point taken, the main advantage here was to just leverage
the single metric lookup we already have anyway to also derive this
indication at minimal cost. But, we will also revisit some different
possibilities, such as evaluating RTAX_CC_ALGO.

I think it could still be solved the current way, if we change fibs to
return with EINVAL in case someone sets a feature bit that is completely
unknown to the kernel (in other words, one of the remaining unused 28
bits) of that metric value, then it could be solved by hiding all this
entirely in kernel space. Perhaps some part of that bit range might also
be interesting for future kernel-only features to be indicated there in
the dst metric w/o any exposure.

Thanks for your feedback,
Daniel
