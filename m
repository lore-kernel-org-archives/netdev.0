From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] Fix build on fedora-14 (and other older systems)
Date: Sun, 3 Sep 2017 08:50:04 -0700
Message-ID: <20170903085004.5b5ded4f@xeon-e3>
References: <1504361702-30266-1-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:35409 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753049AbdICPuH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 3 Sep 2017 11:50:07 -0400
Received: by mail-pf0-f169.google.com with SMTP id g13so12022730pfm.2
        for <netdev@vger.kernel.org>; Sun, 03 Sep 2017 08:50:07 -0700 (PDT)
In-Reply-To: <1504361702-30266-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat,  2 Sep 2017 07:15:02 -0700
greearb@candelatech.com wrote:

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

I am not accepting this patch because all files in include/linux are automatically
regenerated from kernel 'make install_headers'. No exceptions. If you want to change
a header in include/linux it has to go through upstream kernel inclusion.
