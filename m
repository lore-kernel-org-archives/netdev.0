From: "Cherukuru, Siva Ramaprasad" <sivaramaprasad.c@hpe.com>
Subject: RE: latest iproute2 compilation issue with linux-4.6-rc7
Date: Fri, 10 Jun 2016 11:44:01 +0000
Message-ID: <TU4PR84MB0174ACA7816B501BD939CF0082500@TU4PR84MB0174.NAMPRD84.PROD.OUTLOOK.COM>
References: <DF4PR84MB0169ABB98113BCC2AB9CD625825F0@DF4PR84MB0169.NAMPRD84.PROD.OUTLOOK.COM>
 <20160609091010.0ac5d45a@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bn0102.outbound.protection.outlook.com ([157.56.110.102]:10331
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753098AbcFJL7K convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2016 07:59:10 -0400
In-Reply-To: <20160609091010.0ac5d45a@xeon-e3>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi ,

 Thanks for your reply. "make distclean" is also not working for me, still more errors.
I will wait for the official patch but if possible share me the fix changes so that I can 
try using latest TC. 


-----

m_ipt.c:64:1: warning: no previous prototype for 'register_target' [-Wmissing-prototypes]
 register_target(struct iptables_target *me)
 ^
m_ipt.c: In function 'register_target':
m_ipt.c:68:4: error: dereferencing pointer to incomplete type
  me->next = t_list;
    ^
m_ipt.c: At top level:
m_ipt.c:74:1: error: conflicting types for 'xtables_register_target'
 xtables_register_target(struct iptables_target *me)
 ^
In file included from ../include/iptables.h:5:0,
                 from m_ipt.c:20:
../include/xtables.h:444:13: note: previous declaration of 'xtables_register_target' was here
 extern void xtables_register_target(struct xtables_target *me);


----------



Thanks,
Siva.

-----Original Message-----
From: Stephen Hemminger [mailto:stephen@networkplumber.org] 
Sent: Thursday, June 09, 2016 9:40 PM
To: Cherukuru, Siva Ramaprasad <sivaramaprasad.c@hpe.com>
Cc: netdev@vger.kernel.org
Subject: Re: latest iproute2 compilation issue with linux-4.6-rc7

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
