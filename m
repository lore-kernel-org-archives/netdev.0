From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v3] rfkill: Add rfkill-any LED trigger
Date: Mon, 02 Jan 2017 13:21:45 +0100
Message-ID: <1483359705.21014.0.camel@sipsolutions.net>
References: <20161221084533.27006-1-kernel@kempniu.pl>
         (sfid-20161221_094622_545524_B00A9AE7) <1483355533.4596.11.camel@sipsolutions.net>
         (sfid-20170102_121239_821112_5D7AEC4A)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?Q?=D0=9C=D0=B8=D1=85=D0=B0=D0=B8=D0=BB_?=
         =?UTF-8?Q?=D0=9A=D1=80=D0=B8=D0=BD=D0=BA=D0=B8=D0=BD?=
        <krinkin.m.u@gmail.com>, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: =?UTF-8?Q?Micha=C5=82_K=C4=99pie=C5=84?= <kernel@kempniu.pl>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1483355533.4596.11.camel@sipsolutions.net> (sfid-20170102_121239_821112_5D7AEC4A)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> I'm not super happy with this conditional locking - can't we instead
> defer the necessary work to a workqueue, or so, for purposes of the
> LED?

Actually, since you can sleep in here, and do various other things like
scheduling etc. this can't even be correct as is - one thread might be
in the probe and another might also attempt to do some operations that
require the lock but now don't take it.

johannes
