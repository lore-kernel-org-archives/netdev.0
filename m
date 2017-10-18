From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] mac80211: aggregation: Convert timers to use
 timer_setup()
Date: Wed, 18 Oct 2017 22:50:11 +0200
Message-ID: <1508359811.2674.56.camel@sipsolutions.net>
References: <20171017202545.GA115810@beast>
         <1508322566.2674.17.camel@sipsolutions.net>
         <CAGXu5jKY5rTuR_w=zj5Bz06f9OrW35eD4sYfkai2Gac_edG4ag@mail.gmail.com>
         (sfid-20171018_161904_357172_FABB3367)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless <linux-wireless@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Network Development <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGXu5jKY5rTuR_w=zj5Bz06f9OrW35eD4sYfkai2Gac_edG4ag@mail.gmail.com> (sfid-20171018_161904_357172_FABB3367)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2017-10-18 at 07:19 -0700, Kees Cook wrote:
> On Wed, Oct 18, 2017 at 3:29 AM, Johannes Berg
> <johannes@sipsolutions.net> wrote:
> > > This has been the least trivial timer conversion yet. Given the use of
> > > RCU and other things I may not even know about, I'd love to get a close
> > > look at this. I *think* this is correct, as it will re-lookup the tid
> > > entries when firing the timer.
> > 
> > I'm not really sure why you're doing the lookup again? That seems
> > pointless, since you already have the right structure, and already rely
> > on it being valid. You can't really get a new struct assigned to the
> > same TID without the old one being destroyed.
> 
> I couldn't tell what the lifetime expectation was, so I left the
> re-lookup. I assumed it was possible to have a timer fire after the
> structure had been removed from the station structure.

Oh, right, I guess that would've been possible in theory. It's not
actually possible though since the aggregation sessions can't live on
without a station, so I've already made a follow-up patch to remove the
indirection.

johannes
