From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] build: resolve compile error due to missing include
Date: Thu, 18 Apr 2013 15:09:09 -0700
Message-ID: <20130418150909.253b812d@nehalam.linuxnetplumber.net>
References: <1366181614-19837-1-git-send-email-jengelh@inai.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@inai.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:62220 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936638Ab3DRWJk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 18:09:40 -0400
Received: by mail-pd0-f179.google.com with SMTP id x11so1822483pdj.10
        for <netdev@vger.kernel.org>; Thu, 18 Apr 2013 15:09:40 -0700 (PDT)
In-Reply-To: <1366181614-19837-1-git-send-email-jengelh@inai.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 17 Apr 2013 08:53:34 +0200
Jan Engelhardt <jengelh@inai.de> wrote:

> I get a compilation error with linux-glibc-devel-2.6.32 (SLES 11 SP2):
> 
> ipnetns.c: In function 'netns_exec':
> ipnetns.c:156: error: 'MS_SLAVE' undeclared (first use in this function)
> ipnetns.c:156: error: (Each undeclared identifier is reported only once
> ipnetns.c:156: error: for each function it appears in.)
> ipnetns.c:156: error: 'MS_REC' undeclared (first use in this function)
> ipnetns.c: In function 'netns_add':
> ipnetns.c:372: error: 'MS_SHARED' undeclared (first use in this function)
> ipnetns.c:372: error: 'MS_REC' undeclared (first use in this function)
> make[1]: *** [ipnetns.o] Error 1
> 
> This patch fixes that.
> ---
>  ip/ipnetns.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/ip/ipnetns.c b/ip/ipnetns.c
> index b047b97..48b1ad5 100644
> --- a/ip/ipnetns.c
> +++ b/ip/ipnetns.c
> @@ -14,6 +14,7 @@
>  #include <errno.h>
>  #include <unistd.h>
>  #include <ctype.h>
> +#include <linux/fs.h>
>  
>  #include "utils.h"
>  #include "ip_common.h"

Including linux/fs.h is the wrong answer and there is no guarantee that the
installed kernel headers are up to date on the build machine either.
The flags are supposed to be in <sys/mount.h>
to work around the missing values, some manual ifdef's were added yesterday.

Rejected.
