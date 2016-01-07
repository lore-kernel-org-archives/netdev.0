From: =?UTF-8?Q?Jo=C3=A3o_Paulo_Rechi_Vita?= <jprvita@gmail.com>
Subject: Re: [PATCH] net/rfkill: Create "airplane mode" LED trigger
Date: Thu, 7 Jan 2016 11:19:25 -0500
Message-ID: <CA+A7VXW3Fsf2O_xnnZAWxieMMhSP2ngTbhtuJEB1JpMc6EFPxQ@mail.gmail.com>
References: <1451142303-1872-1-git-send-email-jprvita@endlessm.com>
 <1451142303-1872-2-git-send-email-jprvita@endlessm.com> <6DC3AA8C-DDE9-44B8-91C5-94B1EB0DBE9A@holtmann.org>
 <1452076319.2541.3.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Marcel Holtmann <marcel@holtmann.org>,
	Network Development <netdev@vger.kernel.org>,
	=?UTF-8?Q?Jo=C3=A3o_Paulo_Rechi_Vita?= <jprvita@endlessm.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Darren Hart <dvhart@infradead.org>,
	platform-driver-x86@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452076319.2541.3.camel@sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

+ Darren Hart and platform-drivers-x86 (sorry, I was trying to avoid
too much cross-posting and ended up leaving interested parties out).

On 6 Jan 2016 05:32, "Johannes Berg" <johannes@sipsolutions.net> wrote:
>
> On Tue, 2016-01-05 at 22:55 -0800, Marcel Holtmann wrote:
> >
> > so I am not convinced the kernel should have the concept of airplan=
e
> > mode at all.
>
> [snip long story]
>
> This is true, but that doesn't mean the patch is bad, just the naming
> could be different.
>
> I think the patch could name this "rfkill-all" (or so) instead, and
> replace all the "airplane_mode" identifiers as well.
>

I agree "airplane mode" is not the best name here and I can change in
an updated version.

> Then the driver can still default to "rfkill-all" trigger, or a
> suitably interested userspace could remove the trigger and manage the
> LED state itself.
>

Trying to answer both Marcel's and your comments, I think we should
rather have a trigger which fires when the global state of
RFKILL_TYPE_ALL changes, instead of tied to the op
RFKILL_OP_CHANGE_ALL. Then we should also update the global states on
every set block operation instead of only on RFKILL_OP_CHANGE_ALL.
This part does not look like policy to me (please correct me if I'm
wrong).

The platform driver can default this trigger and have the LED reflect
the global state of RFKILL_TYPE_ALL. This indeed looks like policy,
but mostly because the physical LED label is an airplane icon, what
the LED will be representing is "all radios are off". If that is not
acceptable in the kernel, I can expose the LED to userspace instead
and different userspaces can decide when to trigger it (in which case
we don't need this patch at all). But considering this is a laptop
platform driver, the only way I can see this being used is having the
LED lit when all the radios are off, and unlit otherwise (maybe I'm
being a bit short-visioned).

In any case, I think we should update the global states on every set
block operation, to have them consistent with the individual states. I
can provide a patch for that.

> Then again - if I think about that more - perhaps the kernel *should*
> have a concept of airplane mode, just one that's not necessarily tied
> to the "rfkill_all" setting, but could be controlled by userspace. Th=
at
> way, userspace wouldn't have to know about the LED, just about the
> airplane mode indicator (for which rfkill would probably be an
> appropriate place)
>

If I'm following this correctly, your suggestion is to have an
"airplane mode indicator" switch in the RFKill subsystem, which would
be driven by userspace and will be tied to a trigger that could be
used by platform drivers to drive physical airplane mode LEDs and
similar. That's an interesting idea and probably better than expecting
userspaces to know about platform details like LED presence. If this
is feasible looks like a nice generic solution for this problem.

Please let me know what you guys think is the best solution so I can wo=
rk on it.

> Two comments on the patch itself:
>
> > +#ifdef CONFIG_RFKILL_LEDS
> > +       led_trigger_register(&amp;airplane_mode_led_trigger);
> > +#endif
>
> Everything else uses inlines to avoid ifdefs, you can do the same her=
e.
> Also, error handling seems necessary.
>

Ok, I can fix this if there is an updated version of this patch.

--
Jo=C3=A3o Paulo Rechi Vita
http://about.me/jprvita
