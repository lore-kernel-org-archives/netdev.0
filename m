From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] netem: fix installs of dist files
Date: Sat, 31 Jul 2010 19:33:22 -0700
Message-ID: <20100731193322.063f0fa5@nehalam>
References: <1276131129-18079-1-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: stephen.hemminger@vyatta.com, netdev@vger.kernel.org
To: Mike Frysinger <vapier@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33559 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753090Ab0HACdY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Jul 2010 22:33:24 -0400
In-Reply-To: <1276131129-18079-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  9 Jun 2010 20:52:09 -0400
Mike Frysinger <vapier@gentoo.org> wrote:

> The tc program searches LIBDIR by default for the .dist files, and that
> defaults to /usr/lib.  But the netem subdir has /lib/ hardcoded which
> means the default build+install results in the files not being found.
> 
> Further, these are plain text files which are read at runtime, so it
> doesn't make sense to give them executable bits.
> 
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>
> ---
>  netem/Makefile |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/netem/Makefile b/netem/Makefile
> index b6ccfc6..e52e125 100644
> --- a/netem/Makefile
> +++ b/netem/Makefile
> @@ -20,9 +20,9 @@ stats: stats.c
>  	$(HOSTCC) $(CCOPTS) -I../include -o $@ $@.c -lm
>  
>  install: all
> -	mkdir -p $(DESTDIR)/lib/tc
> +	mkdir -p $(DESTDIR)$(LIBDIR)/tc
>  	for i in $(DISTDATA); \
> -	do install -m 755 $$i $(DESTDIR)/lib/tc; \
> +	do install -m 644 $$i $(DESTDIR)$(LIBDIR)/tc; \
>  	done
>  
>  clean:


Applied
