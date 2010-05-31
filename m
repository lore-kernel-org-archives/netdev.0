From: fthain@telegraphics.com.au
Subject: Re: [PATCH] mac8390: change an error return code and some cleanup,
 take 4
Date: Mon, 31 May 2010 21:07:09 +1000 (EST)
Message-ID: <alpine.LNX.2.00.1005312011210.469@nippy.intranet>
References: <alpine.OSX.2.00.1004171258330.358@localhost> <20100421.163041.158540277.davem@davemloft.net> <alpine.OSX.2.00.1005290255580.691@localhost> <20100531.001947.193703044.davem@davemloft.net> <alpine.LNX.2.00.1005311905520.469@nippy.intranet>
 <AANLkTilkooBglbk33yDHmk8c_ZdlamOW8FVvuvjQaNsF@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: joe@perches.com, p_gortmaker@yahoo.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-m68k@vger.kernel.org
To: Geert Uytterhoeven <geert@linux-m68k.org>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTilkooBglbk33yDHmk8c_ZdlamOW8FVvuvjQaNsF@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Mon, 31 May 2010, Geert Uytterhoeven wrote:

> 
> `pr_debug()' indeed now may generate code if DEBUG is not defined, i.e. 
> if CONFIG_DYNAMIC_DEBUG is enabled. This is intented for debug 
> infrastructure the user may want to enable later.
> 
> If you want the old behavior, you can use `pr_devel()' instead, which 
> only generates code if DEBUG is defined. This is intended for debug 
> infrastructure for developers only.
> 
> However, you used `printk(KERN_DEBUG pr_fmt()...)`, which always 
> generates code. I'm still not 100% sure that was intentional?

Geert, in the beginning, I decided that it should be KERN_DEBUG, not 
KERN_INFO, and made that change in the first patch submission. I used 
pr_debug().

Then Joe pointed out that this required DEBUG defined, which I'd forgotten 
(I didn't know about CONFIG_DYNAMIC_DEBUG). So, to retain the old 
behaviour, while following the example of other usages of ei_debug in 
lib8390 and drivers, I changed it to printk(KERN_DEBUG ...).

Then Joe pointed out that I should take advantage of pr_fmt(), so the 
third submission made that change.

(Then David said I should propagate the return code from request_irq, so I 
made the present patch submission.)

Apparently David now wants me to submit this again --

if (ei_debug)
	pr_debug(...)

David, if that code is acceptable, please let me know.

If that code is mandatory, why didn't you say so upon the second patch 
submission?

Alternatively, if the following is preferred (as implied by your last 
email):

if (ei_debug)
	pr_info(...)

Then let me know, and I'll quit bothering you.

Or just go ahead and change my patch if you wish to save us both some 
time.

Finn

> 
> Gr{oetje,eeting}s,
> 
> 						Geert
