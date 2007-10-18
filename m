From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH 2/3] Lost locking in fl6_sock_lookup
Date: Thu, 18 Oct 2007 16:11:58 +0400
Message-ID: <47174D8E.2050200@openvz.org>
References: <47174950.6060409@openvz.org> <20071018.210043.51908349.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, devel@openvz.org
To: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:43352 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763116AbXJRMMS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Oct 2007 08:12:18 -0400
In-Reply-To: <20071018.210043.51908349.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki wrote:
> In article <47174950.6060409@openvz.org> (at Thu, 18 Oct 2007 15:53:52 +0400), Pavel Emelyanov <xemul@openvz.org> says:
> 
>> This routine scans the ipv6_fl_list whose update is
>> protected with the socket lock and the ip6_sk_fl_lock.
> 
>>  		struct ip6_flowlabel *fl = sfl->fl;
>>  		if (fl->label == label) {
>> +			read_unlock_bh(&ip6_sk_fl_lock);
>>  			fl->lastuse = jiffies;
>>  			atomic_inc(&fl->users);
>>  			return fl;
> 
> We should increment fl->users within the critical section, shouldn't we?

Not necessary. The users is more than zero (because it is 
linked in the sock's list) so garbage collector won't catch 
it in any way.

Thanks,
Pavel

> --yoshfuji
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

