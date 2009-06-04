From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/8] add lib/gcd.c
Date: Thu, 4 Jun 2009 12:03:40 -0700
Message-ID: <20090604120340.079f6cdf.akpm@linux-foundation.org>
References: <200906041615.10467.florian@openwrt.org>
	<4A27DAAD.5000303@ru.mvista.com>
	<200906041639.04868.florian@openwrt.org>
	<1244131044.3631.14.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <florian@openwrt.org>,
	Sergei Shtylyov <sshtylyov@ru.mvista.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Linux-MIPS <linux-mips@linux-mips.org>,
	linux-kernel@vger.kernel.org, Takashi Iwai <tiwai@suse.de>,
	Ralf Baechle <ralf@linux-mips.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <1244131044.3631.14.camel@Joe-Laptop.home>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

On Thu, 04 Jun 2009 08:57:24 -0700 Joe Perches <joe@perches.com> wrote:

> On Thu, 2009-06-04 at 16:39 +0200, Florian Fainelli wrote:
> > diff --git a/lib/gcd.c b/lib/gcd.c
> > new file mode 100644
> > index 0000000..6634741
> > --- /dev/null
> > +++ b/lib/gcd.c
> > @@ -0,0 +1,20 @@
> > +#include <linux/gcd.h>
> > +#include <linux/module.h>
> > +
> > +/* Greatest common divisor */
> > +unsigned long gcd(unsigned long a, unsigned long b)
> > +{
> > +	unsigned long r;
> > +
> > +	if (a < b) {
> > +		r = a;
> > +		a = b;
> > +		b = r;
> 	swap(a, b)

yup

> > +	}
> > +	while ((r = a % b) != 0) {
> > +		a = b;
> > +		b = r;
> > +	}
> > +	return b;
> > +}
> > +EXPORT_SYMBOL_GPL(gcd);
> 
> Shouldn't a generic gcd protect against a div0
> if gcd(0,0)?

nope.  It's a caller bug, there's nothing the callee can do to fix it,
so an oops is a fine response.
