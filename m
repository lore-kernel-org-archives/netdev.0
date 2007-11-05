From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: Endianness problem with u32 classifier hash masks
Date: Mon, 5 Nov 2007 14:52:46 +0100
Message-ID: <20071105135246.GB1933@ff.dom.local>
References: <1193939701.2987.82.camel@localhost.localdomain> <472B5EF1.4020206@o2.pl> <1194045830.4438.21.camel@localhost> <472D06B2.9040402@o2.pl> <472D0B1C.7000209@o2.pl> <472D128B.8030704@o2.pl> <472D1DC2.9000106@o2.pl> <1194220693.4438.75.camel@localhost> <20071105091231.GA1933@ff.dom.local> <1194267561.2987.141.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <hadi@cyberus.ca>, netdev@vger.kernel.org
To: Radu Rendec <radu.rendec@ines.ro>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx12.go2.pl ([193.17.41.142]:34887 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755440AbXKENtA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Nov 2007 08:49:00 -0500
Content-Disposition: inline
In-Reply-To: <1194267561.2987.141.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 05, 2007 at 02:59:21PM +0200, Radu Rendec wrote:
...
> Jamal, I am aware that any computation on the fast path involves some
> performance loss. However, I don't see any speed gain with your patch,
> because you just moved the ntohl() call inside u32_hash_fold(). Since
> u32_hash_fold() is called unconditionally and the only call is that one
> in u32_classify(), htohl() will be called exactly the same number of
> times.

It seems this performance loss shouldn't be so big because ntohl()
is probably quite well optimized in assembler. But, as I've written,
since there is max. 1 byte meaningful to us there is some additional
possibility to get it other way, but I doubt it's worth to bother,
and this can be done with some later patch, after all.

> 
> After almost a week of dealing with this, I still don't think it can be
> solved without byte re-ordering. If you guys think my patch is good, I
> would be more than glad to send it properly (change the comments as
> Jarek suggested and use git). Since I'm quite a newbie with git and
> haven't worked with kernel maintainers before, please be patient if it's
> not perfect at the first attempt :) What tree/branch should I make the
> patch against?

If we manage to convince Jamal, IMHO a patch to something current like
2.6.24-rc1-git14 (or maybe -rc2 soon), should suffice (plus some
options to diff to get function names etc. eg.: diff -Nurp). Try with
Documentation/SubmittingPatches. Git isn't necessary at all. And don't
forget about a changelog.

Regards,
Jarek P.
