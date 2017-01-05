From: =?utf-8?B?TWljaGHFgiBLxJlwaWXFhA==?= <kernel@kempniu.pl>
Subject: Re: [PATCH v3] rfkill: Add rfkill-any LED trigger
Date: Thu, 5 Jan 2017 15:36:54 +0100
Message-ID: <20170105143654.GA21040@ozzy.nask.waw.pl>
References: <20161221084533.27006-1-kernel@kempniu.pl>
 <1483355533.4596.11.camel@sipsolutions.net>
 <1483359705.21014.0.camel@sipsolutions.net>
 <1483361523.21014.1.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "David S . Miller" <davem@davemloft.net>,
        =?utf-8?B?0JzQuNGF0LDQuNC7INCa0YDQuNC90LrQuNC9?=
        <krinkin.m.u@gmail.com>, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:35564 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759834AbdAEOhF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2017 09:37:05 -0500
Received: by mail-lf0-f68.google.com with SMTP id x140so33337792lfa.2
        for <netdev@vger.kernel.org>; Thu, 05 Jan 2017 06:36:58 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1483361523.21014.1.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Mon, 2017-01-02 at 13:21 +0100, Johannes Berg wrote:
> > > I'm not super happy with this conditional locking - can't we
> > > instead
> > > defer the necessary work to a workqueue, or so, for purposes of the
> > > LED?
> > 
> > Actually, since you can sleep in here, and do various other things
> > like scheduling etc. this can't even be correct as is - one thread
> > might be in the probe and another might also attempt to do some
> > operations that require the lock but now don't take it.
> 
> Additionally, this doesn't address the "can be called in any context"
> part, only the "even from within rfkill callbacks" part. It's clearly
> still not safe to call this from any context that is not allowed to
> sleep, for example.

Thanks for reviewing.  I will attempt a workqueue-based approach in v4.

-- 
Best regards,
Michał Kępień
