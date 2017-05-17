From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 2/6] wl1251: Use request_firmware_prefer_user() for
 loading NVS calibration data
Date: Wed, 17 May 2017 14:06:06 +0200
Message-ID: <1495022766.2442.1.camel@sipsolutions.net>
References: <0fd90416-f33c-a6be-14fd-5e964583e9cb@broadcom.com>
         <20170515231339.GF17314@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Pavel Machek <pavel@ucw.cz>, Daniel Wagner <wagi@monom.org>,
        Tom Gundersen <teg@jklm.no>,
        Pali =?ISO-8859-1?Q?Roh=E1r?= <pali.rohar@gmail.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Kalle Valo <kvalo@codeaurora.org>,
        David Gnedt <david.gnedt@davizone.at>,
        Tony Lindgren <tony@atomide.com>,
        Sebastian Reichel <sre@kernel.org>,
        Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
        Aaro Koskinen <aaro.koskinen@iki.fi>,
        Takashi Iwai <tiwai@suse.de>,
        AKASHI Takahiro <takahiro.akashi@linaro.org>,
        David Woodhouse <dwmw2@infradead.org>,
        Bjorn Andersson <bjorn.andersson@linaro.org>,
        Grazvydas Ignotas <notasas@gmail.com>,
        linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org,
        =?UTF-8?Q?Micha=C5=82?= Kazior <kazikcz@gmail.com>
To: "Luis R. Rodriguez" <mcgrof@kernel.org>,
        Arend Van Spriel <arend.vanspriel@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170515231339.GF17314@wotan.suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2017-05-16 at 01:13 +0200, Luis R. Rodriguez wrote:
> > > Now for N900 case there is a similar scenario
> > > alhtough it has additional requirement to go to user-space due to
> > > need to use a proprietary library to obtain the NVS calibration
> > > data. My thought: Why should firmware_class care?
> 
> Agreed.

In fact, why should the *driver* care either? IOW - why should
"request_firmware_prefer_user()" even exist?

> > > So the idea is that firmware_class provides
> > > a registry for modules that can produce a certain firmware
> > > "file". Those
> > > modules can do whatever is needed. If they need to use umh so be
> > > it.
> > > They would only register themselves with firmware_class on
> > > platforms
> > > that need them. It would basically be replacing the fallback
> > > mechanism
> > > and only be effective on certain platforms.
> 
> Sure, so it sounds like the work that Daniel Wagner and Tom Gundersen
> worked [0] on which provides a firmwared with two modes: best-effort, 
> and final-mode, would address what you are looking for but without
> requiring any upstream changes, *and* it also helps solve the rootfs
> race remote-proc folks had concerns over.

Right.

> The other added gain over this solution is if folks need their own
> proprietary concoction they can just fork firmwared

Or just reimplement it to the same kernel API, no need to even use the
same code base.

> Lastly, if we did not want to deal with timeouts for the way the
> driver data API implements it I think we might be able to do away
> with them for for async requests if we assume there will be a daemon
> that spawns in final-mode eventually, and since it *knows* when the
> rootfs is ready it should be able to do a final lookup, if it returns
> -ENOENT; then indeed we know we can give up. Now, perhaps how and if
> we want to deal with timeouts when using the driver data API for the
> fallback mechanism is worth considering given it does not have a
> fallback mechanism support yet. If we *add* them it would seem this
> would also put an implicit race against userspace finishing
> initialization and running firmwared in final-mode.
> 
> Johannes, do you recall the corner cases we spoke about regarding
> timeouts? Does this match what we spoke about?

I think we have to protect against userspace code crashing, not
existing, etc. - so I think we do need a timeout anyway.

However, I don't recall any (other) corner cases we might have spoken
about.

> Note that firmware signing will require an additional file, the
> detached signature.

Is anything like that happening finally? :)

johannes
> 
