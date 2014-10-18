From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net] ipv6: introduce tcp_v6_iif()
Date: Fri, 17 Oct 2014 17:00:31 -0700
Message-ID: <CAHA+R7PJ7WcFuhvQg+hQ-oBDs8xKdk-jh8+n96NbWoq6XQw8Qg@mail.gmail.com>
References: <1413562640.24953.26.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAHA+R7Od13Bnn3wciLNrA-RsYuYBAjvwAzc20dgGtYT_=EX88w@mail.gmail.com>
	<1413569996.25949.6.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f175.google.com ([209.85.216.175]:45421 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751342AbaJRAAb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2014 20:00:31 -0400
Received: by mail-qc0-f175.google.com with SMTP id b13so1549714qcw.20
        for <netdev@vger.kernel.org>; Fri, 17 Oct 2014 17:00:31 -0700 (PDT)
In-Reply-To: <1413569996.25949.6.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 17, 2014 at 11:19 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2014-10-17 at 09:58 -0700, Cong Wang wrote:
>
>> I doubt we still need to store iif in IP6CB() since we have skb->skb_iif,
>> we can probably just make inet6_iif() be like inet_iif() so that IP6CB()->iif
>> can be just removed? Does this make any sense to you?
>>
>
> This makes sense and would gain 4 bytes in skb->cb[], so definitely
> worth it.
>


Hmm, after testing my patch, I found that some IPv6 code (scope_id) calls
inet6_iif() at socket layer too, where skb dst is already dropped. So we can't
simply use skb_dst() for all inet6_iif(). This is also why IPv4 is different.

Therefore, I think your patch is fine at least for net.
