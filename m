From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH v5 net-next] net: Implement fast csum_partial for x86_64
Date: Mon, 7 Mar 2016 17:39:04 -0800
Message-ID: <CA+55aFwvjK16LDhztbmkvLe2wm=G5MXA2_rC=CksUgbTcvb-pA@mail.gmail.com>
References: <1456957112-2702469-1-git-send-email-tom@herbertland.com>
	<063D6719AE5E284EB5DD2968C1650D6D41113AD4@AcuExch.aculab.com>
	<CA+55aFzz7xt+RwruV3GvWJzQ67925gkDYeOYqgbjMEAHxxztnQ@mail.gmail.com>
	<063D6719AE5E284EB5DD2968C1650D6D41114809@AcuExch.aculab.com>
	<CAKgT0UcQEkhbpBvT69tBKvmY1EVm91vMwVUHOdkE4RJ3hH+Q9g@mail.gmail.com>
	<063D6719AE5E284EB5DD2968C1650D6D41116831@AcuExch.aculab.com>
	<CALx6S35h+oSCKsaEotah30tspZPdp3GZThrN8=cLbE2O7nhU2g@mail.gmail.com>
	<CAKgT0UfKA=ugpxuUYmv_DaEErRvEDFbGkhHDaFCxDM9C5YzeCQ@mail.gmail.com>
	<CALx6S378j3WKvHc6_NQ1544gjSu7mp_OsE9xGzXnCrBCusNjOw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	David Laight <David.Laight@aculab.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"tglx@linutronix.de" <tglx@linutronix.de>,
	"mingo@redhat.com" <mingo@redhat.com>,
	"hpa@zytor.com" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>,
	"kernel-team@fb.com" <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:36656 "EHLO
	mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753390AbcCHBjG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 20:39:06 -0500
Received: by mail-io0-f193.google.com with SMTP id m184so756581iof.3
        for <netdev@vger.kernel.org>; Mon, 07 Mar 2016 17:39:05 -0800 (PST)
In-Reply-To: <CALx6S378j3WKvHc6_NQ1544gjSu7mp_OsE9xGzXnCrBCusNjOw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 7, 2016 at 4:07 PM, Tom Herbert <tom@herbertland.com> wrote:
>
> As I said previously, if alignment really is a factor then we can
> check up front if a buffer crosses a page boundary and call the slow
> path function (original code). I'm seeing a 1 nsec hit to add this
> check.

It shouldn't be a factor, and you shouldn't check for it. My code was
self-aligning, and had at most one unaligned access at the beginnig
(the data of which was then used to align the rest).

Tom had a version that used that. Although now that I look back at it,
it seems to be broken by some confusion about the one-byte alignment
vs 8-byte alignment.

             Linus
