From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 4/5] net: Refactor inetpeer address struct
Date: Thu, 27 Aug 2015 15:52:39 -0700
Message-ID: <55DF94B7.5000605@cumulusnetworks.com>
References: <1440710193-4824-1-git-send-email-dsa@cumulusnetworks.com>
 <1440710193-4824-5-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:36453 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752685AbbH0Wwq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 18:52:46 -0400
Received: by pacgr6 with SMTP id gr6so3178185pac.3
        for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 15:52:46 -0700 (PDT)
Received: from [10.40.10.138] ([216.129.126.126])
        by smtp.googlemail.com with ESMTPSA id oe10sm3547988pbc.11.2015.08.27.15.52.44
        for <netdev@vger.kernel.org>
        (version=TLSv1/SSLv3 cipher=OTHER);
        Thu, 27 Aug 2015 15:52:45 -0700 (PDT)
In-Reply-To: <1440710193-4824-5-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/27/15 2:16 PM, David Ahern wrote:
> @@ -124,12 +122,12 @@ static inline struct inet_peer *inet_getpeer_v6(struct inet_peer_base *base,
>   static inline int inetpeer_addr_cmp(const struct inetpeer_addr *a,
>   				    const struct inetpeer_addr *b)
>   {
> -	int i, n = (a->family == AF_INET ? 1 : 4);
> +	int i, n = (a->family == AF_INET ? sizeof(a->a4) : sizeof(a->a6));

Forgot the / by sizeof(u32) (key size) in this version of the patches. 
v2 coming.

>
>   	for (i = 0; i < n; i++) {
> -		if (a->addr.a6[i] == b->addr.a6[i])
> +		if (a->key[i] == b->key[i])
>   			continue;
> -		if ((__force u32)a->addr.a6[i] < (__force u32)b->addr.a6[i])
> +		if (a->key[i] < b->key[i])
>   			return -1;
>   		return 1;
>   	}
>
