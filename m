From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: + security-selinux-include-netlabelh-fix-two-build-errors.patch
 added to -mm tree
Date: Thu, 4 Sep 2008 21:00:33 -0700
Message-ID: <20080904210033.20700500.randy.dunlap@oracle.com>
References: <200809050326.m853QB13012853@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, paul.moore@hp.com,
	netdev <netdev@vger.kernel.org>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:40049 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750716AbYIEEAt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2008 00:00:49 -0400
In-Reply-To: <200809050326.m853QB13012853@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 04 Sep 2008 20:26:11 -0700 akpm@linux-foundation.org wrote:

> The patch titled
>      security/selinux/include/netlabel.h: fix two build errors
> has been added to the -mm tree.  Its filename is
>      security-selinux-include-netlabelh-fix-two-build-errors.patch
> 
> Before you just go and hit "reply", please:
>    a) Consider who else should be cc'ed
>    b) Prefer to cc a suitable mailing list as well
>    c) Ideally: find the original patch on the mailing list and do a
>       reply-to-all to that, adding suitable additional cc's
> 
> *** Remember to use Documentation/SubmitChecklist when testing your code ***
> 
> See http://www.zip.com.au/~akpm/linux/patches/stuff/added-to-mm.txt to find
> out what to do about this
> 
> The current -mm tree may be found at http://userweb.kernel.org/~akpm/mmotm/
> 
> ------------------------------------------------------
> Subject: security/selinux/include/netlabel.h: fix two build errors
> From: Andrew Morton <akpm@linux-foundation.org>
> 
> security/selinux/include/netlabel.h:74: error: two or more data types in declaration specifiers
> security/selinux/include/netlabel.h:106: error: expected ';', ',' or ')' before 'u32'
> 
> Caused by
> 
>     commit b023202e2a41a61165f472cc889f37c4a260ba51
>     Author: Paul Moore <paul.moore@hp.com>
>     Date:   Tue Sep 2 10:24:41 2008 -0400
> 
>         selinux: Fix missing calls to netlbl_skbuff_err()
> 
> Cc: Paul Moore <paul.moore@hp.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  security/selinux/include/netlabel.h |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff -puN security/selinux/include/netlabel.h~security-selinux-include-netlabelh-fix-two-build-errors security/selinux/include/netlabel.h
> --- a/security/selinux/include/netlabel.h~security-selinux-include-netlabelh-fix-two-build-errors
> +++ a/security/selinux/include/netlabel.h
> @@ -71,7 +71,7 @@ static inline void selinux_netlbl_cache_
>  	return;
>  }
>  
> -static inline void void selinux_netlbl_err(struct sk_buff *skb,
> +static inline void selinux_netlbl_err(struct sk_buff *skb,
>  					   int error,
>  					   int gateway)
>  {
> @@ -102,7 +102,7 @@ static inline int selinux_netlbl_skbuff_
>  }
>  
>  static inline int selinux_netlbl_skbuff_setsid(struct sk_buff *skb,
> -					       u16 family
> +					       u16 family,
>  					       u32 sid)
>  {
>  	return 0;
> _


Even with this patch, net/netlabel/netlabel_mgmt.c has build errors when CONFIG_IPV6=n:

linux-next-20080904/net/netlabel/netlabel_domainhash.c:79: warning: unused variable 'tmp6'
linux-next-20080904/net/netlabel/netlabel_domainhash.c:78: warning: unused variable 'iter6'
linux-next-20080904/net/netlabel/netlabel_domainhash.c:340: warning: unused variable 'tmp6'
linux-next-20080904/net/netlabel/netlabel_domainhash.c:301: warning: unused variable 'iter6'
linux-next-20080904/net/netlabel/netlabel_mgmt.c:219: error: implicit declaration of function 'netlbl_af6list_add'
linux-next-20080904/net/netlabel/netlabel_mgmt.c:317: error: implicit declaration of function 'netlbl_af6list_foreach_rcu'
linux-next-20080904/net/netlabel/netlabel_mgmt.c:318: error: expected ';' before '{' token
make[3]: *** [net/netlabel/netlabel_mgmt.o] Error 1

---
~Randy
Linux Plumbers Conference, 17-19 September 2008, Portland, Oregon USA
http://linuxplumbersconf.org/
