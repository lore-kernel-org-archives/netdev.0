From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH v2] isdn/gigaset: Convert timers to use timer_setup()
Date: Fri, 06 Oct 2017 21:00:33 +0200
Message-ID: <1507316433.6960.19.camel@tiscali.nl>
References: <20171005193118.GA105874@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Karsten Keil <isdn@linux-pingi.de>,
        "David S. Miller" <davem@davemloft.net>,
        Johan Hovold <johan@kernel.org>, linux-kernel@vger.kernel.org,
        gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171005193118.GA105874@beast>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2017-10-05 at 12:31 -0700, Kees Cook wrote:
> --- a/drivers/isdn/gigaset/bas-gigaset.c
> +++ b/drivers/isdn/gigaset/bas-gigaset.c

> -static void cmd_in_timeout(unsigned long data)
> +static void cmd_in_timeout(struct timer_list *t)
>  {
> -	struct cardstate *cs = (struct cardstate *) data;
> -	struct bas_cardstate *ucs = cs->hw.bas;
> +	struct bas_cardstate *ucs = from_timer(ucs, t, timer_cmd_in);
> +	struct urb *urb = ucs->urb_int_in;
> +	struct cardstate *cs = urb->context;

This makes me nervous. Are you sure urb->context points to a struct cardstate
here and in the other two places this patch changes?

Anyhow, I'd like to have some time to do my review. So what's your timeframe
here? I do hope I have at least a few weeks. (In other words: I hope gigaset
isn't the only driver where the ability to use random pointers in these timer
callbacks is removed.)

Thanks,


Paul Bolle
