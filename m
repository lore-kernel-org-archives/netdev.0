From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Subject: Re: [PATCH 2/6] wl1251: Use request_firmware_prefer_user() for
 loading NVS calibration data
Date: Thu, 4 May 2017 04:28:05 +0200
Message-ID: <20170504022805.GV28800@wotan.suse.de>
References: <1482598381-16513-1-git-send-email-pali.rohar@gmail.com>
 <1482598381-16513-3-git-send-email-pali.rohar@gmail.com>
 <e728586e-80bf-c9e0-0063-71da4c4aba85@broadcom.com>
 <20161226163559.GB27087@amd>
 <20170103175924.GC13946@wotan.suse.de>
 <936bf348-58ac-882c-a433-83f209862deb@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Luis R. Rodriguez" <mcgrof@kernel.org>,
        Pavel Machek <pavel@ucw.cz>, Daniel Wagner <wagi@monom.org>,
        Tom Gundersen <teg@jklm.no>,
        Pali =?iso-8859-1?Q?Roh=E1r?= <pali.rohar@gmail.com>,
        Ming Lei <ming.lei@canonical.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Kalle Valo <kvalo@codeaurora.org>,
        David Gnedt <david.gnedt@davizone.at>,
        Michal Kazior <michal.kazior@tieto.com>,
        Tony Lindgren <tony@atomide.com>,
        Sebastian Reichel <sre@kernel.org>,
        Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
        Aaro Koskinen <aaro.koskinen@iki.fi>,
        Takashi Iwai <tiwai@suse.de>,
        David Woodhouse <dwmw2@infradead.org>,
        Bjorn Andersson <bjorn.andersson@linaro.org>,
        Grazvydas Ignotas <notasas@gmail.com>,
        linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
To: Arend Van Spriel <arend.vanspriel@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <936bf348-58ac-882c-a433-83f209862deb@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 03, 2017 at 09:02:20PM +0200, Arend Van Spriel wrote:
> On 3-1-2017 18:59, Luis R. Rodriguez wrote:
> > On Mon, Dec 26, 2016 at 05:35:59PM +0100, Pavel Machek wrote:
> >>
> >> Right question is "should we solve it without user-space help"?
> >>
> >> Answer is no, too. Way too complex. Yes, it would be nice if hardware
> >> was designed in such a way that getting calibration data from kernel
> >> is easy, and if you design hardware, please design it like that. But
> >> N900 is not designed like that and getting the calibration through
> >> userspace looks like only reasonable solution.
> > 
> > Arend seems to have a better alternative in mind possible for other
> > devices which *can* probably pull of doing this easily and nicely,
> > given the nasty history of the usermode helper crap we should not
> > in any way discourage such efforts.
> > 
> > Arend -- please look at the firmware cache, it not a hash but a hash
> > table for an O(1) lookups would be a welcomed change, then it could
> > be repurposed for what you describe, I think the only difference is
> > you'd perhaps want a custom driver hook to fetch the calibration data
> > so the driver does whatever it needs.
> 
> Hi Luis,
> 
> I let my idea catch dust on the shelf for a while. 

:) BTW did you get to check out Daniel Wagner and Tom Gundersen's firmware work
[0] ? This can provide a proper clear fallback mechanism which *also* helps
address the race between "critical mount points ready" problem we had discussed
long ago. IIRC it did this by having two modes of operation a best effort-mode
and a final-mode. The final-mode would only be used once all the real rootfs is
ready. Userspace decides when to kick / signal firmwared to switch to final-mode
as only userspace will know for sure when that is ready. The best-effort mode
would be used in initramfs. There is also no need for a "custom fallback", the
uevent fallback mechanism can be relied upon alone. Custom tools can just fork
off and do something similar to firmward then in terms of architecture. This is
a form of fallback mechanism I think I'd be happy to see enabled on the new
driver data API. But of course, I recall also liking what you had in mind as well
so would be happy to see more alternatives! The cleaner the better !

[0] https://github.com/teg/firmwared

> Actually had a couple
> of patches ready, but did get around testing them. So I wanted to rebase
> them on your linux-next tree. I bumped into the umh lock thing and was
> wondering why direct filesystem access was under that lock as well.

Indeed, it was an odd thing.

> In your tree I noticed a fix for that. 

Yup!

It took a lot of git archeology to reach a sound approach forward which makes
me feel comfortable without regressing the kernel, this should not regress
the kernel.

> The more reason to base my work on
> top of your firmware_class changes. Now my question is what is the best
> branch to choose, because you have a "few" in that repo to choose from ;-)

I have a series of topical changes, and I rebase onto the latest linux-next
regularly before posting patches, if 0-day finds issues, I dish out a next
try2 or tryX iteration until all issues are fixed. So in this case you'd
just go for the latest driver-data-$(next_date) and if there is a try
postfix use the latest tryX.

In this case 20170501-driver-data-try2, this is based on linux-next tag
next-20170501. If you have issues booting on that next tag though you
could instead try the v4.11-rc8-driver-data-try3 branch based on v4.11-rc8.
But naturally patches ultimately should be based on the latest linux-next
tag for actual submission.

PS. after my changes the fallback mechanism can easily be shoved into its
own file, not sure if that helps with how clean of a solution your work
will be.

  Luis
