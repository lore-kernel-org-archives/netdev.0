From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: skb_splice_bits() and large chunks in pipe (was Re:
 xfs_file_splice_read: possible circular locking dependency detected
Date: Sun, 18 Sep 2016 17:18:34 -0700
Message-ID: <CA+55aFx3L3WbjC3vwpj=LDWEUsSYrUHONOjpRYs4h0BHEC57Ew@mail.gmail.com>
References: <CA+55aFwHQMjO4-vtfB9-ytc=o+DRo-HXVGckvXLboUxgpwb7_g@mail.gmail.com>
 <20160909221945.GQ2356@ZenIV.linux.org.uk> <CA+55aFzTOOB6oEVaaGD0N7Uznk-W9+ULPwzsxS_L_oZqGVSeLA@mail.gmail.com>
 <20160914031648.GB2356@ZenIV.linux.org.uk> <CA+55aFznQaOWoSMNphgGJJWZ=8-odrc0DAUMzfGPQe+_N4UgNA@mail.gmail.com>
 <20160914042559.GC2356@ZenIV.linux.org.uk> <20160917082007.GA6489@ZenIV.linux.org.uk>
 <20160917190023.GA8039@ZenIV.linux.org.uk> <20160918193112.GF2356@ZenIV.linux.org.uk>
 <CA+55aFx5Y=Rddw3ObnOm-XSUkJezfxzNGuTckD2ChVmJRNsD2g@mail.gmail.com> <20160918223117.GH2356@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jens Axboe <axboe@kernel.dk>, Nick Piggin <npiggin@gmail.com>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>
To: Al Viro <viro@zeniv.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f44.google.com ([209.85.218.44]:33424 "EHLO
        mail-oi0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932405AbcISASf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2016 20:18:35 -0400
In-Reply-To: <20160918223117.GH2356@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 18, 2016 at 3:31 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
>
> What worries me is iov_iter_get_pages() and friends.

So honestly, if it worries you, I'm not going to complain at all if
you decide that you'd rather translate the pipe_buffer[] array into a
kvec by always splitting at page boundaries.

Even with large packets in networking, it's not going t be a huge
deal. And maybe we *should* make it a rule that a "kvec" is always
composed of individual entries that fit entirely within a page.

In this code, being safe rather than clever would be a welcome and
surprising change, I guess.

             Linus
