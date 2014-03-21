From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] sh_eth: pm_runtime should not need null operations
Date: Fri, 21 Mar 2014 11:30:16 +0100
Message-ID: <CAMuHMdWO-kNdWT_AxzAmCTrx3NerWpTG+auFNZTcL5hsbN+++A@mail.gmail.com>
References: <1395396913-24354-1-git-send-email-ben.dooks@codethink.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-kernel@lists.codethink.co.uk,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux-sh list <linux-sh@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Ben Dooks <ben.dooks@codethink.co.uk>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1395396913-24354-1-git-send-email-ben.dooks@codethink.co.uk>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Ben,

On Fri, Mar 21, 2014 at 11:15 AM, Ben Dooks <ben.dooks@codethink.co.uk> wrote:
> The driver has a no-op for the pm_runtime callbacks but
> the pm_runtime core should correctly ignore drivers without
> any pm_rumtime callback ops.

The pm_runtime core doesn't ignore non-existing runtime_{suspend,resume}
callbacks, it turns them into a failure withv -ENOSYS.
Only non-existing runtime_idle callbacks are ignored.

rpm_suspend():

        callback = rpm_get_suspend_cb(dev);

        retval = rpm_callback(callback, dev);
        if (retval)
                goto fail;

(rpm_callback() returns -ENOSYS if !callback).

pm_runtime_force_suspend():

        callback = rpm_get_suspend_cb(dev);

        if (!callback) {
                ret = -ENOSYS;
                goto err;
        }

Same for resume.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
