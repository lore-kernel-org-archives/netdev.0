From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [git patches] 2.6.x net driver updates
Date: Thu, 12 Jan 2006 14:30:19 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0601121423120.3535@g5.osdl.org>
References: <20060112221322.GA25470@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030381AbWALWac@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20060112221322.GA25470@havoc.gtf.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Thu, 12 Jan 2006, Jeff Garzik wrote:
> 
> dann frazier:
>       CONFIG_AIRO needs CONFIG_CRYPTO

I think this is done wrong.

It should "select CRYPTO" rather than "depends on CRYPTO".

Otherwise people won't see it just because they don't have crypto enabled, 
which is not very user-friendly.

Btw, why are these casts there? Either the functions are of the right 
type, or they aren't. In neither case is the cast correct.

I do realize that there are comments in <net/iw_handler.h> that says that 
you should do the cast, but that's no excuse for crap or stupid code.

If it's an issue of trying to make greppable code, why not have
just the comment?

> @@ -2378,6 +2566,15 @@ static const iw_handler atmel_handler[] 
>  	(iw_handler) atmel_get_encode,		/* SIOCGIWENCODE */
>  	(iw_handler) atmel_set_power,		/* SIOCSIWPOWER */
>  	(iw_handler) atmel_get_power,		/* SIOCGIWPOWER */
> +	(iw_handler) NULL,			/* -- hole -- */
> +	(iw_handler) NULL,			/* -- hole -- */
...

Hmm?

		Linus
