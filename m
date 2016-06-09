From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: latest iproute2 compilation issue with linux-4.6-rc7
Date: Thu, 9 Jun 2016 09:10:10 -0700
Message-ID: <20160609091010.0ac5d45a@xeon-e3>
References: <DF4PR84MB0169ABB98113BCC2AB9CD625825F0@DF4PR84MB0169.NAMPRD84.PROD.OUTLOOK.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Cherukuru, Siva Ramaprasad" <sivaramaprasad.c@hpe.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:34464 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932082AbcFIQOc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 12:14:32 -0400
Received: by mail-pa0-f44.google.com with SMTP id bz2so14148157pad.1
        for <netdev@vger.kernel.org>; Thu, 09 Jun 2016 09:14:32 -0700 (PDT)
In-Reply-To: <DF4PR84MB0169ABB98113BCC2AB9CD625825F0@DF4PR84MB0169.NAMPRD84.PROD.OUTLOOK.COM>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 9 Jun 2016 11:46:38 +0000
"Cherukuru, Siva Ramaprasad" <sivaramaprasad.c@hpe.com> wrote:

> Hi ,
> 
>       When I try to compile latest iproute2 code, I am seeing the following errors.
> Please let me know if there is any workaround available Or fix for this issue?
> 
> ====
> 
> In file included from m_ipt.c:19:0:
> ../include/linux/if.h:106:19: error: redeclaration of enumerator 'IFF_UP'
> #define IFF_UP    IFF_UP
>                    ^
> ../include/linux/if.h:79:2: note: previous definition of 'IFF_UP' was here
>   IFF_UP    = 1<<0,  /* sysfs */
>  ^
> ../include/linux/if.h:107:25: error: redeclaration of enumerator 'IFF_BROADCAST'
> #define IFF_BROADCAST   IFF_BROADCAST
>                          ^
> ../include/linux/if.h:80:2: note: previous definition of 'IFF_BROADCAST' was here
>   IFF_BROADCAST   = 1<<1,  /* __volatile__ */
>   ^
> ../include/linux/if.h:108:21: error: redeclaration of enumerator 'IFF_DEBUG'
> #define IFF_DEBUG   IFF_DEBUG
>                      ^
> ../include/linux/if.h:81:2: note: previous definition of 'IFF_DEBUG' was here
>   IFF_DEBUG   = 1<<2,  /* sysfs */
>   ^
> 
> ...
> ...
> 
> In file included from ../include/iptables.h:5:0,
>                  from m_ipt.c:22:
> ../include/xtables.h:34:29: fatal error: xtables-version.h: No such file or directory
> #include <xtables-version.h>
>                              ^
> compilation terminated.
> make[1]: *** [m_ipt.o] Error 1
> rm emp_ematch.lex.c
> make: *** [all] Error 2
> 
> =========
> 
> I have tried the following to work around the errors  but still stuck with the xtables-version.h error?
> 
> ===
> root@dock1:~/siva_iproute2/iproute2# git diff tc/m_ipt.c
> diff --git a/tc/m_ipt.c b/tc/m_ipt.c
> index d088f5e..1ebd2f7 100644
> --- a/tc/m_ipt.c
> +++ b/tc/m_ipt.c
> @@ -14,7 +14,9 @@
> #include <sys/socket.h>
> #include <netinet/in.h>
> #include <arpa/inet.h>
> +#ifndef linux/if.h
> #include <linux/if.h>
> +#endif
> #include <iptables.h>
> #include <linux/netfilter.h>
> #include <linux/netfilter_ipv4/ip_tables.h>
> 
> ====
> 
> 
>     CC       m_ipt.o
> In file included from ../include/iptables.h:5:0,
>                  from m_ipt.c:23:
> ../include/xtables.h:34:29: fatal error: xtables-version.h: No such file or directory
> #include <xtables-version.h>
>                              ^
> compilation terminated.
> make[1]: *** [m_ipt.o] Error 1
> rm emp_ematch.lex.c

The update to iptables headers broke compilation because they switched to
xtables.

For now, do
 $ make distclean
 $ make

There is a patch to fix this, but it got no review/feedback and was not submitted
in proper form to netdev for review. Therefore I am waiting for correct fix
to come.
