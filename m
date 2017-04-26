From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 4/6] bpf: track if the bpf program was loaded
 with SYS_ADMIN capabilities
Date: Wed, 26 Apr 2017 14:08:28 -0700
Message-ID: <20170426210826.mlwuuhq7jsu4n7f4@ast-mbp>
References: <20170426182419.14574-1-hannes@stressinduktion.org>
 <20170426182419.14574-5-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, ast@kernel.org, daniel@iogearbox.com,
        jbenc@redhat.com, aconole@bytheb.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35375 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S967724AbdDZVIb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 17:08:31 -0400
Received: by mail-pf0-f195.google.com with SMTP id a188so2703631pfa.2
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2017 14:08:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170426182419.14574-5-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 26, 2017 at 08:24:17PM +0200, Hannes Frederic Sowa wrote:
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
>  include/linux/filter.h | 6 ++++--
>  kernel/bpf/core.c      | 4 +++-
>  kernel/bpf/syscall.c   | 7 ++++---
>  kernel/bpf/verifier.c  | 4 ++--
>  net/core/filter.c      | 6 +++---
>  5 files changed, 16 insertions(+), 11 deletions(-)
> 
> diff --git a/include/linux/filter.h b/include/linux/filter.h
> index 63624c619e371b..635311f57bf24f 100644
> --- a/include/linux/filter.h
> +++ b/include/linux/filter.h
> @@ -413,7 +413,8 @@ struct bpf_prog {
>  				locked:1,	/* Program image locked? */
>  				gpl_compatible:1, /* Is filter GPL compatible? */
>  				cb_access:1,	/* Is control block accessed? */
> -				dst_needed:1;	/* Do we need dst entry? */
> +				dst_needed:1,	/* Do we need dst entry? */
> +				priv_cap_sys_admin:1; /* Where we loaded as sys_admin? */

This is no go.
You didn't provide any explanation whatsoever why you want to see this boolean value.
