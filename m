From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH v2] isdn/gigaset: Convert timers to use timer_setup()
Date: Fri, 6 Oct 2017 12:39:56 -0700
Message-ID: <CAGXu5jJaMODs0NNasPY97wiXeQJ-Y5G+qLrFbwquhGJj=o3rxA@mail.gmail.com>
References: <20171005193118.GA105874@beast> <1507316433.6960.19.camel@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Karsten Keil <isdn@linux-pingi.de>,
        "David S. Miller" <davem@davemloft.net>,
        Johan Hovold <johan@kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        gigaset307x-common@lists.sourceforge.net,
        Network Development <netdev@vger.kernel.org>
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1507316433.6960.19.camel@tiscali.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 6, 2017 at 12:00 PM, Paul Bolle <pebolle@tiscali.nl> wrote:
> On Thu, 2017-10-05 at 12:31 -0700, Kees Cook wrote:
>> --- a/drivers/isdn/gigaset/bas-gigaset.c
>> +++ b/drivers/isdn/gigaset/bas-gigaset.c
>
>> -static void cmd_in_timeout(unsigned long data)
>> +static void cmd_in_timeout(struct timer_list *t)
>>  {
>> -     struct cardstate *cs = (struct cardstate *) data;
>> -     struct bas_cardstate *ucs = cs->hw.bas;
>> +     struct bas_cardstate *ucs = from_timer(ucs, t, timer_cmd_in);
>> +     struct urb *urb = ucs->urb_int_in;
>> +     struct cardstate *cs = urb->context;
>
> This makes me nervous. Are you sure urb->context points to a struct cardstate
> here and in the other two places this patch changes?
>
> Anyhow, I'd like to have some time to do my review. So what's your timeframe
> here? I do hope I have at least a few weeks. (In other words: I hope gigaset
> isn't the only driver where the ability to use random pointers in these timer
> callbacks is removed.)

Hi!

I'm in no rush for any specific change. There are about 900 call sites
I'm making my way through, about 2/3rd are pretty trivial, and the
less obvious is what I've started sending out now, since I expect some
will need some more careful review.

Thanks for taking a look at it!

-Kees

-- 
Kees Cook
Pixel Security
