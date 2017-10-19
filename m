From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH 32/58] isdn/gigaset: Convert timers to use timer_setup()
Date: Fri, 20 Oct 2017 00:16:34 +0200
Message-ID: <1508451394.2274.49.camel@tiscali.nl>
References: <1508200182-104605-1-git-send-email-keescook@chromium.org>
         <1508200182-104605-33-git-send-email-keescook@chromium.org>
         <1508447002.2274.14.camel@tiscali.nl> <1508448028.2274.21.camel@tiscali.nl>
         <CAGXu5j+TLfGAaHb8QLD0faaq6njuPUxStorxFSG7t_8gY-Jymw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Karsten Keil <isdn@linux-pingi.de>,
        Johan Hovold <johan@kernel.org>,
        gigaset307x-common@lists.sourceforge.net,
        Network Development <netdev@vger.kernel.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        LKML <linux-kernel@vger.kernel.org>
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGXu5j+TLfGAaHb8QLD0faaq6njuPUxStorxFSG7t_8gY-Jymw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2017-10-19 at 14:31 -0700, Kees Cook wrote:
> What I did in many other non-trivial conversions was just add an
> explicit pointer back, since that's operationally identical to what
> struct timer_list was storing in its .data field.
> 
> i.e.
> 
> add:
> 
>   struct cardstate *cs;
> 
> to struct bas_cardstate, and then use this on timer entry:
> 
>        struct bas_cardstate *ucs = from_timer(ucs, t, $timer...);
>        struct cardstate *cs = ucs->cs;

That crossed my mind too. (Honestly!) It _feels_ a bit dirty, as I have this
idea that structures having references to each other is some sort of an anti-
pattern. On the other hand: the various structures used here are, well, not
that clean already so I might as well ignore my feelings.

> and this at init:
> 
>         spin_lock_init(&ucs->lock);
> +      ucs->cs = cs;
> -       setup_timer(&ucs->timer_ctrl, req_timeout, (unsigned long) cs);
> -       setup_timer(&ucs->timer_atrdy, atrdy_timeout, (unsigned long) cs);
> -       setup_timer(&ucs->timer_cmd_in, cmd_in_timeout, (unsigned long) cs);
> -       setup_timer(&ucs->timer_int_in, int_in_resubmit, (unsigned long) cs);
> +       timer_setup(&ucs->timer_ctrl, req_timeout, 0);
> +       timer_setup(&ucs->timer_atrdy, atrdy_timeout, 0);
> +       timer_setup(&ucs->timer_cmd_in, cmd_in_timeout, 0);
> +       timer_setup(&ucs->timer_int_in, int_in_resubmit, 0);
> 
> which will avoid the urb entirely.
> 
> Do you want me to send an alternative patch?

That would be nice! Please allow a few days for testing.

That testing is beyond silly, though. It requires me getting a laptop very
close to the awkward place where my ISDN setup lives. I'll spare you the
details. But that silliness again shows, I'd say, that the gigaset code mainly
exists to see if there's still a pulse in mainline ISDN. Is that enough to
bother? Or should mainline ISDN go the way of, say, IRDA?

But I digress. An alternative patch would be much appreciated.

Thanks,


Paul Bolle
