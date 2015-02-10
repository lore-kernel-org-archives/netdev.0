From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Tue, 10 Feb 2015 13:50:16 -0800
Message-ID: <CA+55aFyqFrf9cRQ7wDSDLNraR+meZ-=dwWdDThtpPtrFFqrcGw@mail.gmail.com>
References: <20150209.191601.1373941323785500419.davem@davemloft.net>
	<CA+55aFxskyQ2CkLJ8c_LDkjTY+kKSJ5N6JPjhewGYXsXcHg7nw@mail.gmail.com>
	<20150209.205209.1524645061817000265.davem@davemloft.net>
	<CA+55aFxrGRjL_d=aCZQ0sNC+pfW8nYDLb4KkUVAme5oHmjBjTw@mail.gmail.com>
	<CA+55aFwxuMcNPU-C5p2hSWuNhJW+DOi3Py0NQ--Rw9_bv3md2w@mail.gmail.com>
	<CA+55aFzJNNDi0YKXnNYF=ccYvXALRxzngiV1tARd6CdCimVRYg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Al Viro <viro@zeniv.linux.org.uk>,
	Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:33009 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754153AbbBJVuQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2015 16:50:16 -0500
In-Reply-To: <CA+55aFzJNNDi0YKXnNYF=ccYvXALRxzngiV1tARd6CdCimVRYg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 10, 2015 at 1:26 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> Just to confirm that yes, it's that particular commit 1d10eb2f156f.
>
> I reverted it and things work again. So it's not the miscalculation of
> "used" , but it's certainly *something* in that commit.

How about this?

-       npages = (off + len + PAGE_SIZE - 1) >> PAGE_SHIFT;
+       npages = PAGE_ALIGN(off + n);

The two are not even *remotely* the same thing.

It's in af_alg_make_sg(), and it would seem to cause sg_init_table()
and the loop that does sg_set_page() do insane things. Possibly
including random memory scribbles etc. Which could explain anything.

Anyway, I'm now working on the other pulls I have, so I'll leave this
for now, but I think that might be it.

                         Linus
