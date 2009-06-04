From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 1/8] add lib/gcd.c
Date: Thu, 04 Jun 2009 08:57:24 -0700
Message-ID: <1244131044.3631.14.camel@Joe-Laptop.home>
References: <200906041615.10467.florian@openwrt.org>
	 <4A27DAAD.5000303@ru.mvista.com>  <200906041639.04868.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Sergei Shtylyov <sshtylyov@ru.mvista.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Linux-MIPS <linux-mips@linux-mips.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, Takashi Iwai <tiwai@suse.de>,
	Ralf Baechle <ralf@linux-mips.org>
To: Florian Fainelli <florian@openwrt.org>
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <200906041639.04868.florian@openwrt.org>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

On Thu, 2009-06-04 at 16:39 +0200, Florian Fainelli wrote:
> diff --git a/lib/gcd.c b/lib/gcd.c
> new file mode 100644
> index 0000000..6634741
> --- /dev/null
> +++ b/lib/gcd.c
> @@ -0,0 +1,20 @@
> +#include <linux/gcd.h>
> +#include <linux/module.h>
> +
> +/* Greatest common divisor */
> +unsigned long gcd(unsigned long a, unsigned long b)
> +{
> +	unsigned long r;
> +
> +	if (a < b) {
> +		r = a;
> +		a = b;
> +		b = r;
	swap(a, b)
> +	}
> +	while ((r = a % b) != 0) {
> +		a = b;
> +		b = r;
> +	}
> +	return b;
> +}
> +EXPORT_SYMBOL_GPL(gcd);

Shouldn't a generic gcd protect against a div0
if gcd(0,0)?
