From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v3] rfkill: Add rfkill-any LED trigger
Date: Mon, 02 Jan 2017 13:52:03 +0100
Message-ID: <1483361523.21014.1.camel@sipsolutions.net>
References: <20161221084533.27006-1-kernel@kempniu.pl>
         (sfid-20161221_094622_545524_B00A9AE7) <1483355533.4596.11.camel@sipsolutions.net>
         (sfid-20170102_121239_821112_5D7AEC4A) <1483359705.21014.0.camel@sipsolutions.net>
         (sfid-20170102_132212_994207_4FFA7191)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?Q?=D0=9C=D0=B8=D1=85=D0=B0=D0=B8=D0=BB_?=
         =?UTF-8?Q?=D0=9A=D1=80=D0=B8=D0=BD=D0=BA=D0=B8=D0=BD?=
        <krinkin.m.u@gmail.com>, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: =?UTF-8?Q?Micha=C5=82_K=C4=99pie=C5=84?= <kernel@kempniu.pl>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:39000 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755468AbdABMwI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 2 Jan 2017 07:52:08 -0500
In-Reply-To: <1483359705.21014.0.camel@sipsolutions.net> (sfid-20170102_132212_994207_4FFA7191)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-01-02 at 13:21 +0100, Johannes Berg wrote:
> > I'm not super happy with this conditional locking - can't we
> > instead
> > defer the necessary work to a workqueue, or so, for purposes of the
> > LED?
> 
> Actually, since you can sleep in here, and do various other things
> like scheduling etc. this can't even be correct as is - one thread
> might be in the probe and another might also attempt to do some
> operations that require the lock but now don't take it.

Additionally, this doesn't address the "can be called in any context"
part, only the "even from within rfkill callbacks" part. It's clearly
still not safe to call this from any context that is not allowed to
sleep, for example.

johannes
