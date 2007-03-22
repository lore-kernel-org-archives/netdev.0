From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: RFC: Established connections hash function
Date: Thu, 22 Mar 2007 21:21:56 +0300
Message-ID: <20070322182156.GB17793@2ka.mipt.ru>
References: <10189ABA61CF4D5AB3881F96C9CACE87@XEON> <20070322155227.GA18557@2ka.mipt.ru> <391F64D0A7C5463CA2D70362E4B3E7EC@XEON>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
To: "Nikolaos D. Bougalis" <nikb@webmaster.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:57948 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934170AbXCVSWX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Mar 2007 14:22:23 -0400
Content-Disposition: inline
In-Reply-To: <391F64D0A7C5463CA2D70362E4B3E7EC@XEON>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 22, 2007 at 10:32:44AM -0700, Nikolaos D. Bougalis (nikb@webmaster.com) wrote:
>    Utterly broken? Nonsense. I have tested the actual function I proposed 
> (sans the __force and __u32 stuff, which weren't necessary in my test 
> program), against real data, collected from various servers in real-time. 
> It has consistently achieved lower average chain lengths than the vanilla 
> function and demonstrated no artifacting, and that's trivial to verify.

So what?
People test and work with XOR hash for years and they do not strike any
problems. If we talk about specially crafted data, then XOR one is no
worse than Jenkins with 3 words (which is even worse for blind attack of 
constant ports).

>    The only analysis I could find was this 
> http://tservice.net.ru/~s0mbre/blog/2006/05/14#2006_05_14, which uses 
> jhash_2words, and not jhash_3words, and which naively attempts to take the 
> output of jhash_2words, and to perform the same mixing trick that the 
> vanilla inet_ehashfn does and uses artificially generated data sets.

It is outdated, check recent netdev@ archives. Folding used in that test
does not change distribution, and data was presented as it can be
selected by attacker, who can create with any distribution.

>    But please, feel free to point out any other _unfavorable_ analyses of 
> jhash_2words or jhash_3words that I may have missed.
> 
> 
> >We can use jhash_2words(laddr, faddr, portpair^inet_ehash_rnd) though.
> 
>    Please explain to me how jhash_2words solves the issue that you claim 
> jhash_3words has, when they both use the same underlying bit-mixer?

$c value is not properly distributed and significanly breaks overall
distribution. Attacker, which controls $c (and it does it by controlling 
ports), can significantly increase selected hash chains.

But it is only $c, $a and $b are properly distributed, so jhash_2words()
is safer than jhash_3words().
Just create a simple application which does
jhash_3words(a, b, rand(), init) and jhash_2words(a, b, rand()) and see
results.

I want to emphasize: it is not about random generator, but about data,
controlled by attacker, which can select it like in tests. $c in
jhash_3words() is the weakest part, jhash_2words() works much better in
that regard.

-- 
	Evgeniy Polyakov
