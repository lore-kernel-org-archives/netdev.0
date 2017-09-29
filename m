From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2] lib: fix multiple strlcpy definition
Date: Fri, 29 Sep 2017 11:58:58 -0700
Message-ID: <20170929115858.275217b8@xeon-e3>
References: <6910008ec8db3f63c8120b1624a08328cd203e92.1506621731.git.baruch@tkos.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Phil Sutter <phil@nwl.cc>
To: Baruch Siach <baruch@tkos.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:52968 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752294AbdI2S7G (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2017 14:59:06 -0400
Received: by mail-pf0-f178.google.com with SMTP id p87so251562pfj.9
        for <netdev@vger.kernel.org>; Fri, 29 Sep 2017 11:59:06 -0700 (PDT)
In-Reply-To: <6910008ec8db3f63c8120b1624a08328cd203e92.1506621731.git.baruch@tkos.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 28 Sep 2017 21:02:11 +0300
Baruch Siach <baruch@tkos.co.il> wrote:

> Some C libraries, like uClibc and musl, provide BSD compatible
> strlcpy(). Add check_strlcpy() to configure, and avoid defining strlcpy
> and strlcat when the C library provides them.
> 
> This fixes the following static link error with uClibc-ng:
> 
> .../sysroot/usr/lib/libc.a(strlcpy.os): In function `strlcpy':
> strlcpy.c:(.text+0x0): multiple definition of `strlcpy'
> ../lib/libutil.a(utils.o):utils.c:(.text+0x1ddc): first defined here
> collect2: error: ld returned 1 exit status
> 
> Acked-by: Phil Sutter <phil@nwl.cc>
> Signed-off-by: Baruch Siach <baruch@tkos.co.il>

This is OK because it doesn't impact normal glibc too much.


> diff --git a/lib/Makefile b/lib/Makefile
> index 0fbdf4c31f50..132ad00c3335 100644
> --- a/lib/Makefile
> +++ b/lib/Makefile
> @@ -1,5 +1,9 @@
>  include ../config.mk
>  
> +ifeq ($(NEED_STRLCPY),y)
> +	CFLAGS += -DNEED_STRLCPY
> +endif
> +
>

I just removed all the conditional CFLAGS out of subdirectory Makefiles
and moved them into the generated config.mk. Please do that for this
as well and resubmit.
