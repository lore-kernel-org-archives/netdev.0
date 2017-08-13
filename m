From: Andreas Born <futur.andy-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Subject: Re: Regression: Bug 196547 - Since 4.12 - bonding module not working
 with wireless drivers
Date: Sun, 13 Aug 2017 19:42:53 +0200
Message-ID: <CADps9UCgqeUh41iHxCM+CTJh=Tffn-tiSYL2Q+NBb_8EppqRMA@mail.gmail.com>
References: <87shh0gewn.fsf@kamboji.qca.qualcomm.com> <8845e49b-3165-e6df-5935-c86278d220d9@broadcom.com>
 <CADps9UA7S2betC-+5sOXjYWmDC8gnk6JJ9aEueEOoYAC3DU8hg@mail.gmail.com>
 <87tw1edz5j.fsf@kamboji.qca.qualcomm.com> <87tw1dck6o.fsf@kamboji.qca.qualcomm.com>
 <deb37db2-a55b-4010-475a-e756e67d3bc9@nurealm.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        Arend van Spriel <arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Mahesh Bandewar <maheshb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        Andy Gospodarek <andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: James Feeney <james-fvV4AYHggTTR7s880joybQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <deb37db2-a55b-4010-475a-e756e67d3bc9-fvV4AYHggTTR7s880joybQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

2017-08-12 21:30 GMT+02:00 James Feeney <james-fvV4AYHggTTR7s880joybQ@public.gmane.org>:
>
>
> Andreas patch failed to address the continuous, *10-times per second* warning
> which will "spam" the log file, sometimes the console, whenever the test fails:
>  if (bond_update_speed_duplex(slave) && bond_needs_speed_duplex(bond)) {...}
> which then has:
>  netdev_warn(bond->dev, "failed to get link speed/duplex for%s\n",
>                         slave->dev->name);
>
> That is the sort of irresponsible code that "works fine" as long as there are no
> errors, and it never actually runs!
>
> I'm guessing that the simple fix is to use "net_warn_ratelimited()" instead of
> "netdev_warn()", where net/core/utils.c says:
>
> /*
>  * All net warning printk()s should be guarded by this function.
>  */
> int net_ratelimit(void)
> {
>         return __ratelimit(&net_ratelimit_state);
> }
>
> though Andreas has also suggested "pr_warn_ratelimited()", which instead uses
> "__ratelimit(&_rs)".
>
> Here's a link to the rate-limiting patch, after Andreas' patch is already
> applied, since you say that David has already applied the first patch:
>
> https://bugzilla.kernel.org/attachment.cgi?id=257903
>

The other day I also sent a patch for part 2 of your bug report on
this list. Better safe than sorry by doing one thing per patch. This
second patch received feedback and its v2 is currently awaiting
review. Sorry, for informing you only now. I should have cc'd you in
the first place. You can lookup the state of that patch on patchwork.
[1] It's basically the same as previous versions just changing the
original code even less.
.
I sort of expect that this second patch won't be queued for stable.
But let's see... Essentially it's a regression too and additionally
would've been fixed by a plain revert.

On a side note I would recommend some of my own reading to you about
patch submission in general [1] and on netdev specifically [2].
Putting your suggested changes in the right form makes everyone's life
easier especially your own saving you lots of back and forth by mail.
Seeing the amount of mail on this list during the last days was reason
enough to comprehend the necessity of those standards.

And, just wondering, who's going to eventually close that bugreport?
https://bugzilla.kernel.org/show_bug.cgi?id=196547

Cheers
Andreas

[1] https://patchwork.ozlabs.org/patch/800770/
[2] https://www.kernel.org/doc/html/latest/process/submitting-patches.html
[3] https://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git/tree/Documentation/networking/netdev-FAQ.txt
