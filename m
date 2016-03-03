From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH v5 net-next] net: Implement fast csum_partial for x86_64
Date: Thu, 3 Mar 2016 10:43:37 -0800
Message-ID: <CA+55aFzz7xt+RwruV3GvWJzQ67925gkDYeOYqgbjMEAHxxztnQ@mail.gmail.com>
References: <1456957112-2702469-1-git-send-email-tom@herbertland.com>
	<063D6719AE5E284EB5DD2968C1650D6D41113AD4@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tom Herbert <tom@herbertland.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"tglx@linutronix.de" <tglx@linutronix.de>,
	"mingo@redhat.com" <mingo@redhat.com>,
	"hpa@zytor.com" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>,
	"kernel-team@fb.com" <kernel-team@fb.com>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f195.google.com ([209.85.213.195]:36403 "EHLO
	mail-ig0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751002AbcCCSni (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 13:43:38 -0500
Received: by mail-ig0-f195.google.com with SMTP id ir4so186580igb.3
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2016 10:43:38 -0800 (PST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D41113AD4@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 3, 2016 at 8:12 AM, David Laight <David.Laight@aculab.com> wrote:
>
> Did you try the asm loop that used 'leax %rcx..., jcxz... jmps..'
> without any unrolling?

Is that actually supposed to work ok these days? jcxz used to be quite
slow, and is historically *never* used.

Now, in theory, loop constructs can actually do better on branch
prediction etc, but Intel seems to have never really tried to push
them, and has instead pretty much discouraged them in favor of making
the normal jumps go faster (including all the instruction fusion etc)

>From what I have seen, the whole "don't use LOOP or JRCXZ" has not changed.

           Linus
