From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: Unsigned widening casts of binary "not" operations..
Date: Tue, 23 Apr 2013 07:29:00 -0700
Message-ID: <CA+55aFwogFL=nm=YHwARcz9OTRBdWEDPG0xcqM-H3k-VZTOZPQ@mail.gmail.com>
References: <CA+55aFwpLu0qNms=hkQr43yqD0K9DgESNm91OEWKT1ZuT8MU6Q@mail.gmail.com>
	<CA+55aFy0jPr5udwJx8cZ-QFs-OgZzQ_NJm_VSj_cS7tsKUn3Kw@mail.gmail.com>
	<AE90C24D6B3A694183C094C60CF0A2F6026B71EF@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ingo Molnar <mingo@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	David Miller <davem@davemloft.net>,
	"Theodore Ts'o" <tytso@mit.edu>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"the arch/x86 maintainers" <x86@kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>
To: David Laight <David.Laight@aculab.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B71EF@saturn3.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 23, 2013 at 1:59 AM, David Laight <David.Laight@aculab.com> wrote:
>
> If the narrower type is signed it is probably even more confusing!
> The high bits will be preserved unless you are masking off bit 31.

Yes. However, that case doesn't trigger with the normal case of small
values. So "~4" works fine with widening, in a way that "~4u" does
not.

Which doesn't mean that you aren't right, it only means that it's
harder to check for in sparse. The hacky little patch I sent out with
already resulted in a lot of noise for things like "~0u" (UINT_MAX)
and the "~4u" use in NLMSG_ALIGNTO, I'd dread to do the same for
signed values.

That said, with the most minimal value analysis (ie only looking at
constants), maybe it wouldn't be too bad. I started out just worrying
about the PAGE_MASK case, though, where we're talking about (somewhat
complicated) generated constants, and then the signed case is largely
irrelevant (although a signed "1 << 31" would - as you say - trigger
this same thing too).

                         Linus
