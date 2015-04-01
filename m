From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RFC] iov_iter_get_pages() semantics
Date: Wed, 1 Apr 2015 11:15:17 -0700
Message-ID: <CA+55aFyP4C_x-SPLZZbJaSp6=_nJ01rVp1ABYg0kg_Boi4BfMQ@mail.gmail.com>
References: <20141208164650.GB29028@node.dhcp.inet.fi>
	<20141208175805.GB22149@ZenIV.linux.org.uk>
	<20141208180824.GC22149@ZenIV.linux.org.uk>
	<CA+55aFxwrH4vsyw2ix=HqDK9Z=fw98xtOL8=57prm8qgVmAFfA@mail.gmail.com>
	<20141208182012.GE22149@ZenIV.linux.org.uk>
	<CA+55aFxrrTV-xBbvEzVKsXRVKyvZhQZj-6BNDpTsG4J5k6CJEg@mail.gmail.com>
	<20141208184632.GG22149@ZenIV.linux.org.uk>
	<CA+55aFyh0cV+ztK47mu1QN6aF4VvPE1V5zF7_X2TdYxZ38zZRA@mail.gmail.com>
	<20150401023311.GL29656@ZenIV.linux.org.uk>
	<CA+55aFx0XbzyPJ8zYkSauhTAPVgkqTW5EubaZhg=QgOGHRGkpw@mail.gmail.com>
	<20150401180801.GA889@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Al Viro <viro@zeniv.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:37451 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751964AbbDASPS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 14:15:18 -0400
In-Reply-To: <20150401180801.GA889@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 1, 2015 at 11:08 AM, Al Viro <viro@zeniv.linux.org.uk> wrote:
>>
>> It really is that simple. Either the caller cares about just the
>> content - in which case it should use the normal "iterate over
>> addresses" - or the caller somehow cares about 'struct page' itself,
>> in which case it is *wrong* to do it over vmalloc space or random
>> kernel mappings.
>
> ... or the caller wants sg_table.

Completely immaterial.

Seriously.

If y9ou want an sg-table, how the hell do you know that some user
won't be doing "get_page()" etc on the resulting pages?

Answer: you don't.  If you pass this off to networking or whatever,
and it does some zero-copy thing, it may well be playing games with
the 'struct page'. After all, that's why it exists in the first place.

So no. You *MUST*NOT* turn random vmalloc space (or non-vmalloc space,
for that matter) kernel mappings into struct page arrays. It's wrong.
It's fundamentally invalid crap.

If there are specific cases where it is valid, those specific cases
need to be special-cased.

NO WAY IN HELL do we add generic support for doing shit. Really. If p9
does crazy crap, that is not an excuse to extend the crazy crap to
more code.

                         Linus
