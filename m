From: Andi Kleen <ak@muc.de>
Subject: Re: [ANNOUNCE] Experimental Driver for Neterion/S2io 10GbE Adapters
Date: Tue, 15 Mar 2005 00:27:32 +0100
Message-ID: <m1br9l6c63.fsf@muc.de>
References: <20050314123815.73e7ee78.davem@davemloft.net>
	<200503142054.j2EKs2DD003697@guinness.s2io.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@oss.sgi.com>, <leonid@neterion.com>, <jgarzik@pobox.com>,
        alex@neterion.com
To: "Leonid Grossman" <leonid.grossman@neterion.com>
In-Reply-To: <200503142054.j2EKs2DD003697@guinness.s2io.com> (Leonid
 Grossman's message of "Mon, 14 Mar 2005 12:53:57 -0800")
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

"Leonid Grossman" <leonid.grossman@neterion.com> writes:
>
> Do you have other objections to the submission? We'd like to see if these
> could be addressed; going forward we see significant benefits both for
> S2io/Neterion (and our customers) and for community to use this driver.

I guess the main objection to the HAL comes not from performance
issues (Usually the only thing that really counts for performance
is data cache misses and the HAL is unlikely to affect this much), but
the coding style etc.. Indeed it does not look too Linux like. 

One thing that's frowned upon in Linux are lots of wrappers for
standard functions (like spin_lock etc.). I would recommend
to at least replace them with the standard Linux functions.
In principle this can be even done with some kind of preprocessor
Also less ifdefs would be nice.

An possible compromise might be to get rid of all the HAL parts that
wraps Linux functionality, and then only use a leaner low level
library to access the more difficult parts of the hardware.  This
would involve moving more code into the Linux specific layers. This
should be more low level code, nothing like the high level queue
handling functions you currently have etc., with the high level logic
all in Linux code

-Andi

P.S.: The patch would be much easier to read if it created new
files instead of changing the old ones. This makes sense since
the new driver will probably live next to the old one for some time.
