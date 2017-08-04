From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] iproute2/misc: do not mix CFLAGS with LDFLAGS
Date: Fri, 4 Aug 2017 09:09:10 -0700
Message-ID: <20170804090910.72a1a4ad@xeon-e3>
References: <20170804095402.30943-1-meissner@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Marcus Meissner <meissner@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:32938 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752350AbdHDQJN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 12:09:13 -0400
Received: by mail-pg0-f44.google.com with SMTP id u5so9749110pgn.0
        for <netdev@vger.kernel.org>; Fri, 04 Aug 2017 09:09:12 -0700 (PDT)
In-Reply-To: <20170804095402.30943-1-meissner@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  4 Aug 2017 11:54:02 +0200
Marcus Meissner <meissner@suse.de> wrote:

> during linking, do not use CFLAGS. This avoid clashes when doing PIE builds.
> ---
>  misc/Makefile | 16 ++++++++--------
>  1 file changed, 8 insertions(+), 8 deletions(-)
> 
> diff --git a/misc/Makefile b/misc/Makefile
> index 72807678..1d86c44d 100644
> --- a/misc/Makefile
> +++ b/misc/Makefile
> @@ -23,17 +23,17 @@ all: $(TARGETS)
>  ss: $(SSOBJ)
>  	$(QUIET_LINK)$(CC) $^ $(LDFLAGS) $(LDLIBS) -o $@
>  
> -nstat: nstat.c
> -	$(QUIET_CC)$(CC) $(CFLAGS) $(LDFLAGS) -o nstat nstat.c $(LIBNETLINK) -lm
> +nstat: nstat.o
> +	$(QUIET_CC)$(CC) $(LDFLAGS) -o nstat nstat.o $(LIBNETLINK) -lm
>  
> -ifstat: ifstat.c
> -	$(QUIET_CC)$(CC) $(CFLAGS) $(LDFLAGS) -o ifstat ifstat.c $(LIBNETLINK) -lm
> +ifstat: ifstat.o
> +	$(QUIET_CC)$(CC) $(LDFLAGS) -o ifstat ifstat.o $(LIBNETLINK) -lm
>  
> -rtacct: rtacct.c
> -	$(QUIET_CC)$(CC) $(CFLAGS) $(LDFLAGS) -o rtacct rtacct.c $(LIBNETLINK) -lm
> +rtacct: rtacct.o
> +	$(QUIET_CC)$(CC) $(LDFLAGS) -o rtacct rtacct.o $(LIBNETLINK) -lm
>  
> -arpd: arpd.c
> -	$(QUIET_CC)$(CC) $(CFLAGS) -I$(DBM_INCLUDE) $(LDFLAGS) -o arpd arpd.c $(LIBNETLINK) -ldb -lpthread
> +arpd: arpd.o
> +	$(QUIET_CC)$(CC) $(LDFLAGS) -o arpd arpd.o $(LIBNETLINK) -ldb -lpthread
>  
>  ssfilter.c: ssfilter.y
>  	$(QUIET_YACC)bison ssfilter.y -o ssfilter.c

Some CFLAGS do need to be passed to gcc when doing linking, think of -flto
I don't see this on gcc with Debian and hardening.
