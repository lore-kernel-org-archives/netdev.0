From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2 06/20] ppp: slight optimization of addr compare
Date: Tue, 24 Dec 2013 20:40:46 +0400
Message-ID: <52B9B90E.6040106@cogentembedded.com>
References: <52B96FCD.50901@huawei.com>	 <52B9B559.2060400@cogentembedded.com> <1387902949.2259.51.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ding Tianhong <dingtianhong@huawei.com>,
	Michal Ostrowski <mostrows@earthlink.net>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:56170 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752444Ab3LXQkm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Dec 2013 11:40:42 -0500
Received: by mail-la0-f50.google.com with SMTP id el20so2920299lab.37
        for <netdev@vger.kernel.org>; Tue, 24 Dec 2013 08:40:41 -0800 (PST)
In-Reply-To: <1387902949.2259.51.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 24-12-2013 20:35, Joe Perches wrote:

> []
>>> diff --git a/drivers/net/ppp/pppoe.c b/drivers/net/ppp/pppoe.c
> []
>>> @@ -131,12 +131,13 @@ static inline struct pppoe_net *pppoe_pernet(struct net *net)
>>>
>>>    static inline int cmp_2_addr(struct pppoe_addr *a, struct pppoe_addr *b)
>>>    {
>>> -	return a->sid == b->sid && !memcmp(a->remote, b->remote, ETH_ALEN);
>>> +	return a->sid == b->sid && ether_addr_equal(a->remote,
>>> +							      b->remote);

>>      If it really doesn't fit insto single line, the continuation line should
>> start right under 'a->remote'.

> Better still might be
>
> 	return a->sid == b->sid &&
> 	       ether_addr_equal(a->remote, b->remote);

    Actually, after the second look, I don't know why the line was broken at all.

WBR, Sergei
