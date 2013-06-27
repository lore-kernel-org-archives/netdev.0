From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC Patch net-next 2/5] net: introduce generic inet_pton()
Date: Thu, 27 Jun 2013 14:51:16 -0700
Message-ID: <20130627145116.03e2f892@nehalam.linuxnetplumber.net>
References: <1372315398-19683-1-git-send-email-amwang@redhat.com>
	<1372315398-19683-3-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Daniel Borkmann <dborkman@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Eric Dumazet <edumazet@google.com>,
	linux-kernel@vger.kernel.org
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:34389 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754172Ab3F0VvX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jun 2013 17:51:23 -0400
Received: by mail-pb0-f47.google.com with SMTP id rr13so1453009pbb.6
        for <netdev@vger.kernel.org>; Thu, 27 Jun 2013 14:51:22 -0700 (PDT)
In-Reply-To: <1372315398-19683-3-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 27 Jun 2013 14:43:15 +0800
Cong Wang <amwang@redhat.com> wrote:

> Signed-off-by: Cong Wang <amwang@redhat.com>
> ---
>  include/net/inet_addr.h |   20 ++++++++++++++++++++
>  net/core/netpoll.c      |   24 ++----------------------
>  2 files changed, 22 insertions(+), 22 deletions(-)
> 
> diff --git a/include/net/inet_addr.h b/include/net/inet_addr.h
> index 66a16fe..1379287 100644
> --- a/include/net/inet_addr.h
> +++ b/include/net/inet_addr.h
> @@ -4,6 +4,7 @@
>  #include <linux/in.h>
>  #include <linux/in6.h>
>  #include <linux/socket.h>
> +#include <linux/inet.h>
>  #include <net/addrconf.h>
>  
>  union inet_addr {
> @@ -59,4 +60,23 @@ static inline bool inet_addr_multicast(const union inet_addr *ipa)
>  }
>  #endif
>  
> +static inline int inet_pton(const char *str, union inet_addr *addr)
> +{
>

A couple of comments:
1. No reason for this to be inline
2. If function has same name as userspace it must have same arguments
   and return value. Either:
    a. rename it to kinet_pton or some other name
    b. make it work the same.
