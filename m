From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: Unsigned widening casts of binary "not" operations..
Date: Tue, 23 Apr 2013 11:52:12 -0400
Message-ID: <20130423155212.GI31170@thunk.org>
References: <CA+55aFwpLu0qNms=hkQr43yqD0K9DgESNm91OEWKT1ZuT8MU6Q@mail.gmail.com>
 <CA+55aFy0jPr5udwJx8cZ-QFs-OgZzQ_NJm_VSj_cS7tsKUn3Kw@mail.gmail.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B71EF@saturn3.aculab.com>
 <CA+55aFwogFL=nm=YHwARcz9OTRBdWEDPG0xcqM-H3k-VZTOZPQ@mail.gmail.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B71F2@saturn3.aculab.com>
 <CA+55aFxvpcF7+dyy5d3+JP4Wfv90zPsRVtEhNG9Pky5gWTm_Pg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Laight <David.Laight@aculab.com>,
	Ingo Molnar <mingo@kernel.org>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	the arch/x86 maintainers <x86@kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+55aFxvpcF7+dyy5d3+JP4Wfv90zPsRVtEhNG9Pky5gWTm_Pg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 23, 2013 at 08:42:49AM -0700, Linus Torvalds wrote:
> The best case is for code that does bitmasking ops like this to avoid
> any casts (implicit or explicit) by just avoiding mixed types. That
> was, to a large degree, my hope for the sparse patch, but it's
> nontrivial. Many types are rather "natural" (ie constants have a
> natural "int" type, sizeof() is size_t, etc) and in other cases you
> want to do the same ops for two different types (with the case that
> caused me to start to look at it being the "align to page boundary"
> for a virtual address vs a PAE phys_addr_t) so you can't really avoid
> mixing things in some circumstances.

Maybe it's worth creating a magic helper function, called something
like mask_out() that handles the casting automatically, and it makes
it clear to a reader what you're trying to do?

   	      	     	  	 	   - Ted
