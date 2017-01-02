From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v3] rfkill: Add rfkill-any LED trigger
Date: Mon, 02 Jan 2017 12:12:13 +0100
Message-ID: <1483355533.4596.11.camel@sipsolutions.net>
References: <20161221084533.27006-1-kernel@kempniu.pl>
         (sfid-20161221_094622_545524_B00A9AE7)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?Q?=D0=9C=D0=B8=D1=85=D0=B0=D0=B8=D0=BB_?=
         =?UTF-8?Q?=D0=9A=D1=80=D0=B8=D0=BD=D0=BA=D0=B8=D0=BD?=
        <krinkin.m.u@gmail.com>, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: =?UTF-8?Q?Micha=C5=82_K=C4=99pie=C5=84?= <kernel@kempniu.pl>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161221084533.27006-1-kernel@kempniu.pl> (sfid-20161221_094622_545524_B00A9AE7)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


>   - Handle the global mutex properly when rfkill_set_{hw,sw}_state()
> or
>     rfkill_set_states() is called from within an rfkill callback.  v2
>     always tried to lock the global mutex in such a case, which led
> to a
>     deadlock when an rfkill driver called one of the above functions
>     from its query or set_block callback.  This is solved by defining
> a
>     new bitfield, RFKILL_BLOCK_SW_HASLOCK, which is set before the
> above
>     callbacks are invoked and cleared afterwards; the functions
> listed
>     above use this bitfield to tell rfkill_any_led_trigger_event()
>     whether the global mutex is currently held or not.
>     RFKILL_BLOCK_SW_SETCALL cannot be reused for this purpose as
> setting
>     it before invoking the query callback would cause any calls to
>     rfkill_set_sw_state() made from within that callback to work on
>     RFKILL_BLOCK_SW_PREV instead of RFKILL_BLOCK_SW and thus change
> the
>     way rfkill_set_block() behaves.

I'm not super happy with this conditional locking - can't we instead
defer the necessary work to a workqueue, or so, for purposes of the
LED?

johannes
