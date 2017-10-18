From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH] mac80211: aggregation: Convert timers to use timer_setup()
Date: Wed, 18 Oct 2017 07:19:01 -0700
Message-ID: <CAGXu5jKY5rTuR_w=zj5Bz06f9OrW35eD4sYfkai2Gac_edG4ag@mail.gmail.com>
References: <20171017202545.GA115810@beast> <1508322566.2674.17.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-wireless <linux-wireless@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Network Development <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1508322566.2674.17.camel@sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 18, 2017 at 3:29 AM, Johannes Berg
<johannes@sipsolutions.net> wrote:
>> This has been the least trivial timer conversion yet. Given the use of
>> RCU and other things I may not even know about, I'd love to get a close
>> look at this. I *think* this is correct, as it will re-lookup the tid
>> entries when firing the timer.
>
> I'm not really sure why you're doing the lookup again? That seems
> pointless, since you already have the right structure, and already rely
> on it being valid. You can't really get a new struct assigned to the
> same TID without the old one being destroyed.

I couldn't tell what the lifetime expectation was, so I left the
re-lookup. I assumed it was possible to have a timer fire after the
structure had been removed from the station structure.

-Kees

-- 
Kees Cook
Pixel Security
