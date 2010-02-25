From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 0/7] tcp: bugs and cleanup for 2.6.33
Date: Thu, 25 Feb 2010 20:43:11 +0000
Message-ID: <1267130591.2107.16.camel@achroite.uk.solarflarecom.com>
References: <4B86DDCB.50608@gmail.com>  <4B86DEC6.1090307@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4B86DEC6.1090307@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-02-25 at 15:34 -0500, William Allen Simpson wrote:
> Redefine two TCP header functions to accept TCP header pointer.
> When subtracting, return signed int to allow error checking.

This patch only adds functions, so why do you say 'redefine'?

> These functions will be used in subsequent patches that implement
> additional features.
[...]
> +/* Length of standard options only.  This could be negative. */
> +static inline int tcp_option_len_th(const struct tcphdr *th)
> +{
> +       return (int)(th->doff * 4) - sizeof(*th);
> +}

I don't see  the point of this cast; the left operand of the subtraction
will in any case be promoted to size_t to match the right operand.

Did you mean
	return (int)(th->doff * 4 - sizeof(*th));
?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
