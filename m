From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v4] rfkill: Add rfkill-any LED trigger
Date: Fri, 06 Jan 2017 13:22:13 +0100
Message-ID: <1483705333.4089.6.camel@sipsolutions.net>
References: <20170106060747.6162-1-kernel@kempniu.pl>
         (sfid-20170106_070815_740015_7BAF878D)
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
In-Reply-To: <20170106060747.6162-1-kernel@kempniu.pl> (sfid-20170106_070815_740015_7BAF878D)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2017-01-06 at 07:07 +0100, Michał Kępień wrote:
> Add a new "global" (i.e. not per-rfkill device) LED trigger, rfkill-
> any,
> which may be useful on laptops with a single "radio LED" and multiple
> radio transmitters.  The trigger is meant to turn a LED on whenever
> there is at least one radio transmitter active and turn it off
> otherwise.
> 
> Signed-off-by: Michał Kępień <kernel@kempniu.pl>
> ---
> Changes from v3:
> 
>   - Revert introducing a new bitfield and instead defer LED event
> firing
>     to a work queue to prevent conditional locking and ensure the
>     trigger can really be used from any context.  This also voids the
>     need to take rfkill_global_mutex before calling
> rfkill_set_block()
>     in rfkill_resume().

Looks better, but

> +static struct work_struct rfkill_any_work;

At least on module exit you need to cancel this work.

johannes
