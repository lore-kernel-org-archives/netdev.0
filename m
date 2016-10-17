From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH v4] mac80211: move struct aead_req off the stack
Date: Mon, 17 Oct 2016 16:17:08 +0200
Message-ID: <1476713828.315.5.camel@sipsolutions.net>
References: <1476713133-18355-1-git-send-email-ard.biesheuvel@linaro.org>
         (sfid-20161017_160545_826866_8595CA02)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org, sergey.senozhatsky.work-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: Ard Biesheuvel <ard.biesheuvel-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1476713133-18355-1-git-send-email-ard.biesheuvel-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org> (sfid-20161017_160545_826866_8595CA02)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-10-17 at 15:05 +0100, Ard Biesheuvel wrote:
> From: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

That really ought to have been you - I think I may have lost that by
accident. I'll change it.

> In addition, take care not to put any of our own stack allocations
> into
> scatterlists. This involves reserving some extra room when allocating
> the
> aead_request structures, and referring to those allocations in the
> scatter-
> lists (while copying the data from/to the stack before/after the
> crypto
> operation, as appropriate)

I removed the "to the stack after" language, since that doesn't
actually occur :)


> --- a/net/mac80211/aes_cmac.h
> +++ b/net/mac80211/aes_cmac.h
> @@ -11,6 +11,8 @@
>  
>  #include <linux/crypto.h>
>  
> +#define CMAC_AAD_LEN	20

This part (and aes_cmac.c changes) shouldn't have been there, but that
was my mistake - removed.

With that, I've applied this. Will send it to davem tomorrow.

johannes
