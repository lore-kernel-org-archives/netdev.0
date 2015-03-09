From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH 4/8] net/socket: sys_accept4 - reverse allocation order
Date: Mon, 9 Mar 2015 15:50:24 -0700
Message-ID: <CAHo-Ooxqc75Z7ptiUjFKcFdO2Si3S6_pw28QcyFVzn_js1dfkA@mail.gmail.com>
References: <CAHo-OozBxw=h--dSjhobVfepC_10=H5_9DvXEvrhtnrFvc5tdw@mail.gmail.com>
	<1425936003-24544-1-git-send-email-zenczykowski@gmail.com>
	<1425936003-24544-4-git-send-email-zenczykowski@gmail.com>
	<1425939066.8261.18.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	"Theodore Ts'o" <tytso@mit.edu>,
	Linux NetDev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f49.google.com ([209.85.215.49]:34060 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752461AbbCIWuZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 18:50:25 -0400
Received: by labgq15 with SMTP id gq15so384149lab.1
        for <netdev@vger.kernel.org>; Mon, 09 Mar 2015 15:50:24 -0700 (PDT)
In-Reply-To: <1425939066.8261.18.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Unfortunately this changes accept() behavior when/if ENFILE/EMFILE is
> reported.
>
> Some applications might depend on this behavior to eventually start a
> garbage collection of a cache using file descriptors to regular files.
>
> After your patch, a failed accept() call would silently 'consume' a
> session in the listener queue.

We could in the case of the first failure, attempt to grab a file
descriptor anyway, and if that fails return that failure instead, and
if it succeeds, release it and still return the first failure.

Would that be ok?

> Also, this patch series should be CCed to lkml and Al Viro, as it is a
> mix of fs & network changes.

Ok.
