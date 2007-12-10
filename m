From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [PATCH RFC] [4/9] modpost: Fix format string warnings
Date: Mon, 10 Dec 2007 19:50:39 +0100
Message-ID: <20071210185039.GB17315@uranus.ravnborg.org>
References: <20071122343.446909000@suse.de> <20071122024309.AD8E314D68@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	rusty@rustcorp.com.au
To: Andi Kleen <ak@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pasmtpa.tele.dk ([80.160.77.114]:59891 "EHLO pasmtpA.tele.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751861AbXLJSsu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Dec 2007 13:48:50 -0500
Content-Disposition: inline
In-Reply-To: <20071122024309.AD8E314D68@wotan.suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 22, 2007 at 03:43:09AM +0100, Andi Kleen wrote:
> 
> Fix wrong format strings in modpost exposed by the previous patch.
> Including one missing argument -- some random data was printed instead.

Looks good. Can I get a s-o-b then I will apply it.

	Sam

> 
> ---
>  scripts/mod/modpost.c |    7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
> 
> Index: linux/scripts/mod/modpost.c
> ===================================================================
> --- linux.orig/scripts/mod/modpost.c
> +++ linux/scripts/mod/modpost.c
> @@ -388,7 +388,7 @@ static int parse_elf(struct elf_info *in
>  
>  	/* Check if file offset is correct */
>  	if (hdr->e_shoff > info->size) {
> -		fatal("section header offset=%u in file '%s' is bigger then filesize=%lu\n", hdr->e_shoff, filename, info->size);
> +		fatal("section header offset=%lu in file '%s' is bigger then filesize=%lu\n", (unsigned long)hdr->e_shoff, filename, info->size);
>  		return 0;
>  	}
>  
> @@ -409,7 +409,7 @@ static int parse_elf(struct elf_info *in
>  		const char *secname;
>  
>  		if (sechdrs[i].sh_offset > info->size) {
> -			fatal("%s is truncated. sechdrs[i].sh_offset=%u > sizeof(*hrd)=%ul\n", filename, (unsigned int)sechdrs[i].sh_offset, sizeof(*hdr));
> +			fatal("%s is truncated. sechdrs[i].sh_offset=%lu > sizeof(*hrd)=%lu\n", filename, (unsigned long)sechdrs[i].sh_offset, sizeof(*hdr));
>  			return 0;
>  		}
>  		secname = secstrings + sechdrs[i].sh_name;
> @@ -907,7 +907,8 @@ static void warn_sec_mismatch(const char
>  		     "before '%s' (at offset -0x%llx)\n",
>  		     modname, fromsec, (unsigned long long)r.r_offset,
>  		     secname, refsymname,
> -		     elf->strtab + after->st_name);
> +		     elf->strtab + after->st_name,
> +		     (unsigned long long)r.r_offset);
>  	} else {
>  		warn("%s(%s+0x%llx): Section mismatch: reference to %s:%s\n",
>  		     modname, fromsec, (unsigned long long)r.r_offset,
