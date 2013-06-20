From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 1/5] net: ipv4: using strlcpy instead of strncpy
Date: Thu, 20 Jun 2013 12:17:55 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B729D@saturn3.aculab.com>
References: <1371725385-11540-1-git-send-email-zhaohongjiang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>,
	<yoshfuji@linux-ipv6.org>, <kaber@trash.net>,
	<netdev@vger.kernel.org>
To: "Zhao Hongjiang" <zhaohongjiang@huawei.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:48930 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S965427Ab3FTLfF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 07:35:05 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 22793-02 for <netdev@vger.kernel.org>;
 Thu, 20 Jun 2013 12:35:01 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <1371725385-11540-1-git-send-email-zhaohongjiang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> for NUL terminated string, need alway set '\0' in the end.
> 
> Signed-off-by: Zhao Hongjiang <zhaohongjiang@huawei.com>
> ---
>  net/ipv4/tcp_cong.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
> index 019c238..3280234 100644
> --- a/net/ipv4/tcp_cong.c
> +++ b/net/ipv4/tcp_cong.c
> @@ -170,7 +170,7 @@ void tcp_get_default_congestion_control(char *name)
> 
>  	rcu_read_lock();
>  	ca = list_entry(tcp_cong_list.next, struct tcp_congestion_ops, list);
> -	strncpy(name, ca->name, TCP_CA_NAME_MAX);
> +	strlcpy(name, ca->name, sizeof(name));
>  	rcu_read_unlock();
>  }

Did you actually test this? I think not!

Blindly changing strncpy() to strlcpy() isn't a good idea.
You actually need to worry about the length of both arrays
and whether the source is always 0 terminated.
(Any whether the target is required to be terminated.)
Also, if the target might get copied to user space whether
you might be leaking uninitialized kernel memory.

The one above is just plain wrong though.

	David
