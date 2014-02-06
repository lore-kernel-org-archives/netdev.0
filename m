From: Matija Glavinic Pecotic <matija.glavinic-pecotic.ext@nsn.com>
Subject: Re: [PATCH] net: sctp: fix initialization of local source address
 on accepted ipv6 sockets
Date: Thu, 06 Feb 2014 11:48:33 +0100
Message-ID: <52F36881.1030600@nsn.com>
References: <52F33A02.2040902@nsn.com> <52F36035.4070304@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: ext Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from demumfd001.nsn-inter.net ([93.183.12.32]:12725 "EHLO
	demumfd001.nsn-inter.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754278AbaBFKtY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Feb 2014 05:49:24 -0500
In-Reply-To: <52F36035.4070304@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Daniel,

On 02/06/2014 11:13 AM, ext Daniel Borkmann wrote:
> Hi Matija,
> 
> On 02/06/2014 08:30 AM, Matija Glavinic Pecotic wrote:
>> commit     efe4208f47f907b86f528788da711e8ab9dea44d:
>> 'ipv6: make lookups simpler and faster' broke initialization of local source
>> address on accepted ipv6 sockets. Before the mentioned commit receive address
>> was copied along with the contents of ipv6_pinfo in sctp_v6_create_accept_sk.
>> Now when it is moved, it has to be copied separately.
>>
>> This also fixes lksctp's ipv6 regression in a sense that test_getname_v6, TC5 -
>> 'getsockname on a connected server socket' now passes.
>>
>> Signed-off-by: Matija Glavinic Pecotic <matija.glavinic-pecotic.ext@nsn.com>
> 
> 1) What about the status of http://patchwork.ozlabs.org/patch/311958/ ? Are
>    you still working on a v2?

of course, but as I mentioned, patch breaks regression. I can justify that, but I need to fix those broken TCs. This one got in a way while doing that. I'm also a bit busy lately so thats why I'm slower on that one.

> 2) There already has been some discussion in [1,2] about that issue and an
>    RFC patch for net-next has been proposed in [3] for fixing it on a more
>    general scope. I need to get back to that when net-next opens and when
>    I'm back from the conference trip I'm right now. It's however net-next
>    material for sure.

yes, that one seems to be better solution.

Regards,

Matija

>   [1] http://patchwork.ozlabs.org/patch/292245/
>   [2] http://patchwork.ozlabs.org/patch/292352/
>   [3] http://www.spinics.net/lists/linux-sctp/msg03089.html
> 
> Best,
> 
> Daniel
> 
>> --- net-next.orig/net/sctp/ipv6.c
>> +++ net-next/net/sctp/ipv6.c
>> @@ -662,6 +662,8 @@ static struct sock *sctp_v6_create_accep
>>        */
>>       sctp_v6_to_sk_daddr(&asoc->peer.primary_addr, newsk);
>>
>> +    newsk->sk_v6_rcv_saddr = sk->sk_v6_rcv_saddr;
>> +
>>       sk_refcnt_debug_inc(newsk);
>>
>>       if (newsk->sk_prot->init(newsk)) {
>> -- 
>> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
