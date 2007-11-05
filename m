From: jamal <hadi@cyberus.ca>
Subject: Re: Endianness problem with u32 classifier hash masks
Date: Mon, 05 Nov 2007 08:43:32 -0500
Message-ID: <1194270212.4438.95.camel@localhost>
References: <1193939701.2987.82.camel@localhost.localdomain>
	 <472B5EF1.4020206@o2.pl> <1194045830.4438.21.camel@localhost>
	 <472D06B2.9040402@o2.pl> <472D0B1C.7000209@o2.pl> <472D128B.8030704@o2.pl>
	 <472D1DC2.9000106@o2.pl> <1194220693.4438.75.camel@localhost>
	 <20071105091231.GA1933@ff.dom.local>
	 <1194267561.2987.141.camel@localhost.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@o2.pl>, netdev@vger.kernel.org
To: Radu Rendec <radu.rendec@ines.ro>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.178]:9641 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755434AbXKENsu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2007 08:48:50 -0500
Received: by wa-out-1112.google.com with SMTP id v27so1978041wah
        for <netdev@vger.kernel.org>; Mon, 05 Nov 2007 05:48:49 -0800 (PST)
In-Reply-To: <1194267561.2987.141.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-05-11 at 14:59 +0200, Radu Rendec wrote:
> Jarek, thanks for replying my message on the list and pointing it to the
> right direction.
> 
> Your example with "1" bits laying on exact nibble boundary is much
> easier to analyze than my original example. And your computation seems
> to be right: u32_hash_fold() would return 00.f0.00.0f (and would be cut
> off to 0f after applying the divisor mask).

Yes, that example i believe would work just fine today as is with no
changes.

[...]

> Jamal, I am aware that any computation on the fast path involves some
> performance loss. However, I don't see any speed gain with your patch,
> because you just moved the ntohl() call inside u32_hash_fold(). Since
> u32_hash_fold() is called unconditionally and the only call is that one
> in u32_classify(), htohl() will be called exactly the same number of
> times.
> 

Sorry, I didnt mean that to be a better approach - it suffers the same
problem as what you posted and infact is just your patch simplified
essentially (or my attempt at doing that).
A simpler version would be to do something in u32_change() only and
nowhere else. Thats what i alluded at using fshift. And even after
taking a shower i cant think of a simple way to achieve it.

> After almost a week of dealing with this, I still don't think it can be
> solved without byte re-ordering. If you guys think my patch is good, I
> would be more than glad to send it properly (change the comments as
> Jarek suggested and use git). Since I'm quite a newbie with git and
> haven't worked with kernel maintainers before, please be patient if it's
> not perfect at the first attempt :) What tree/branch should I make the
> patch against?
> 

Please try the patch i sent since it is simpler. It is your work more or
less - so you should get the credit as author. 
Use Davem's net-2.6 as basis. If it works send it to him and CC me and i
will just wsignoff/ack.
If it doesnt work, can you cutdown on the conversion in u32_change()
instead and send that?

cheers,
jamal

