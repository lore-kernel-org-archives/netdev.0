From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCHv4 wl-drv-next 0/2] register-field manipulation macros
Date: Tue, 05 Jul 2016 16:24:18 +0300
Message-ID: <87lh1g2p6l.fsf@kamboji.qca.qualcomm.com>
References: <1467718979-20029-1-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org, nbd-Vt+b4OUoWG0@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
To: Jakub Kicinski <jakub.kicinski-wFxRvT7yatFl57MIdRCFDg@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1467718979-20029-1-git-send-email-jakub.kicinski-wFxRvT7yatFl57MIdRCFDg@public.gmane.org>
	(Jakub Kicinski's message of "Tue, 5 Jul 2016 12:42:57 +0100")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Jakub Kicinski <jakub.kicinski-wFxRvT7yatFl57MIdRCFDg@public.gmane.org> writes:

> This set moves to a global header file macros which I find
> very useful and worth popularising.  The basic problem is
> that since C bitfields are not very dependable accessing
> subfields of registers becomes slightly inconvenient.
> It is nice to have the necessary mask and shift operations
> wrapped in a macro.  It is also nice to have that macro
> compute the shift amount based on the mask automatically.
>
> My implementation follows what Felix Fietkau has done in
> mt76.  Hannes Frederic Sowa suggested more use of standard
> Linux/GCC functions.  Since the RFC I've also added a 
> compile-time check to validate that the value passed to
> setters fits in the mask.
>
> I attempted the use of static inlines instead of macros
> but it makes GCC < 6.0 barf at the BUILD_BUG_ON()s.
> I also noticed that forcing arguments to be u32 for inlines
> makes the compiler use 32bit arithmetic where it could
> get away with 64bit before (on 64bit machines, obviously).
> That's a potential performance concern but probably not
> a very practical one today.  Apart from looking "cleaner"
> static inlines would have the advantage that we could #undef
> the auxiliary macros at the end of the header.

This information about various compiler problems is good to have in the
commit log as the cover letter itself is not stored in the git log.

> v3:
> Build bot caught a build failure with -Os set.  AFAICT gcc
> did not handle temporary variable I put in the macro
> expression too well.  I work around that by defining
> __BUILD_BUG_ON_NOT_POWER_OF_2 and using it instead of
> BUILD_BUG_ON(!tmp || is_power_of_2(tmp)).
>
> Please review and advise on improvements.
>
> If accepted I think would be best to push this through
> Kalle's tree, since the only existing user is in
> drivers/net/wireless/.

I like it. But I feel much more comfortable to take these if I get an
ack from someone like Dave Miller or Andrew Morton (CCed).

Full patches here:

https://patchwork.kernel.org/patch/9214129/
https://patchwork.kernel.org/patch/9214135/

-- 
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
