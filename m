From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RFC] iov_iter_get_pages() semantics
Date: Wed, 1 Apr 2015 11:26:38 -0700
Message-ID: <CA+55aFyOZ5LD-mAOb_OafJe-VMy0hxrgOCB5hJ=GXJAFP7e8dQ@mail.gmail.com>
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
Received: from mail-ie0-f177.google.com ([209.85.223.177]:36038 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751964AbbDAS0j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 14:26:39 -0400
In-Reply-To: <20150401180801.GA889@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 1, 2015 at 11:08 AM, Al Viro <viro@zeniv.linux.org.uk> wrote:
>
> IOW, do you have a problem with obtaining a pointer to kernel page and
> immediately shoving it into scatterlist?

And just to clarify, yes I do. Why the f*ck wasn't it a struct page to
begin with? And why do you think that a scatter-list is somehow "safe"
and guarantees people won't be playing (invalid and completely broken)
games with page counters etc that you cannot play for those things?

If this is just about finit_module(), then dammit, why the f*ck does
it even try to do zero-copy in the first place? But if that's the only
use, maybe we can improve on kernel_read() to do some aio-read on the
raw pages instead. And change the "info->hdr" thing to not just do a
blind vmalloc, but actually do the page allocations and then do
vmap_page_range() to map in the end result after IO etc.

IOW, it's fine to do IO on 'struct page', but it should be
*controlled* and you damn well need to _own_ that struct page and its
lifetime, no just "look up random struct page from some kernel
address".

                        Linus
