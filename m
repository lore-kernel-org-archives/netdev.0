From: Junio C Hamano <gitster@pobox.com>
Subject: Re: [PATCH 02/27] drivers/net: fix sparse warnings: make do-while a
 compound statement
Date: Wed, 24 Dec 2008 22:17:15 -0800
Message-ID: <7vd4fgdbis.fsf@gitster.siamese.dyndns.org>
References: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net>
 <20081222191507.11807.50794.stgit@vmbox.hanneseder.net>
 <m3hc4voo2a.fsf@maximus.localdomain>
 <a01a16b50812221544x45c3559ap808ac0095ee8f01@mail.gmail.com>
 <m3ocz2ua3w.fsf@maximus.localdomain> <1230053186.1447.9.camel@brick>
 <m3k59qssix.fsf@maximus.localdomain>
 <alpine.LFD.2.00.0812231008350.3535@localhost.localdomain>
 <m3hc4usco9.fsf@maximus.localdomain>
 <alpine.LFD.2.00.0812231529030.3535@localhost.localdomain>
 <m3myemqqgp.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Harvey Harrison <harvey.harrison@gmail.com>,
	=?utf-8?B?SMOla29uIEzDuHZkYWw=?= <hlovdal@gmail.com>,
	Hannes Eder <hannes@hanneseder.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a-sasl-fastnet.sasl.smtp.pobox.com ([207.106.133.19]:57499 "EHLO
	sasl.smtp.pobox.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750948AbYLYGR3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Dec 2008 01:17:29 -0500
In-Reply-To: <m3myemqqgp.fsf@maximus.localdomain> (Krzysztof Halasa's message
 of "Wed, 24 Dec 2008 03:03:50 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Krzysztof Halasa <khc@pm.waw.pl> writes:

> Linus Torvalds <torvalds@linux-foundation.org> writes:
> ...
>> Another example of "common vs non-common" is this:
>>
>> 	if (0 <= x)
>> 		do something..
>>
>> is something that crazy people do (sadly, one of the crazy people taught 
>> the git maintainer C programming, so now even sane people do it). It's 
>> crazy because it's uncommon, which means that most people have to think 
>> about it A LOT MORE than about
>>
>> 	if (x >= 0)
>> 		do something..
>
> No. It's crazy not because it's uncommon, but because this is how we
> have been taught in school.
>
> I don't know reasons for "0 >= x" but I know one for
> 	if (0 == x)
> 		do something..
>
> It's because people sometimes write "=" instead of "==" and "0 = x"
> doesn't make sense to gcc.

It does not have anything to do with the assignment confusion.

It is "textual order should reflect actual order" (aka "have number line
in your head when you write your comparison conditional"):

    http://thread.gmane.org/gmane.comp.version-control.git/3903/focus=4126

Even if it may make logical sense, I would not suggest using it when other
people are not familiar with the convention, though.

