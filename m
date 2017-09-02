From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH] Fix build on fedora-14 (and other older systems)
Date: Sat, 2 Sep 2017 19:03:36 +0200
Message-ID: <20170902170336.piispo3i3xk62pxq@unicorn.suse.cz>
References: <1504361702-30266-1-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:47412 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752732AbdIBRDi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 2 Sep 2017 13:03:38 -0400
Content-Disposition: inline
In-Reply-To: <1504361702-30266-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 02, 2017 at 07:15:02AM -0700, greearb@candelatech.com wrote:
> From: Ben Greear <greearb@candelatech.com>
> 
> Seems Fedora-20 and below fail, hopefully this fixes
> them.
> 
> Signed-off-by: Ben Greear <greearb@candelatech.com>
> ---
>  include/linux/sysinfo.h | 8 ++++++++
>  ip/ipxfrm.c             | 1 +
>  ip/xfrm_policy.c        | 1 +
>  ip/xfrm_state.c         | 1 +
>  4 files changed, 11 insertions(+)

Works for me from openSUSE Tumbleweed to SLE11 SP4 (kernel 3.0). The
build on SLE11 SP2 (also 3.0 but older headers in /usr/include)
fails with unknown MS_PRIVATE and MS_REC in lib/bpf.c
Newer systems have these defined in <sys/mount.h>

Including <linux/fs.h> directly in lib/bpf.c fixes that but if we do
that, a copy of the file would have to be included.

> diff --git a/include/linux/sysinfo.h b/include/linux/sysinfo.h
> index 934335a..3596b02 100644
> --- a/include/linux/sysinfo.h
> +++ b/include/linux/sysinfo.h
> @@ -3,6 +3,14 @@
>  
>  #include <linux/types.h>
>  
> +/* So we can compile on older OSs, hopefully this is correct. --Ben */
> +#ifndef __kernel_long_t
> +typedef long __kernel_long_t;
> +#endif
> +#ifndef __kernel_ulong_t
> +typedef unsigned long __kernel_ulong_t;
> +#endif
> +
>  #define SI_LOAD_SHIFT	16
>  struct sysinfo {
>  	__kernel_long_t uptime;		/* Seconds since boot */

I'm not sure if it is acceptable to modify a file which is supposed to
be a direct copy of kernel uapi header.

Michal Kubecek
