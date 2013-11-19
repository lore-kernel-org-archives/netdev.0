From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net] net: sctp: fix copying sk_v6_rcv_saddr in sctp_v6_create_accept_sk
Date: Tue, 19 Nov 2013 16:46:59 +0100
Message-ID: <528B87F3.7030407@redhat.com>
References: <1384858284-2246-1-git-send-email-dborkman@redhat.com> <528B85E2.5080403@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org, Wang Weidong <wangweidong1@huawei.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40500 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752864Ab3KSPrJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Nov 2013 10:47:09 -0500
In-Reply-To: <528B85E2.5080403@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/19/2013 04:38 PM, Vlad Yasevich wrote:
> On 11/19/2013 05:51 AM, Daniel Borkmann wrote:
>> Wang reported an issue that lksctp's test_getname_v6 seems to fail.
>>
>> The issue is that we do not copy sk_v6_rcv_saddr over to the new
>> socket, although the comment above says so regarding rcv_saddr.
>>
>> Commit 914e1c8b6980 ("sctp: Inherit all socket options from parent
>> correctly.") originally moved that over to sctp_copy_sock(), but
>> after commit efe4208f47f9 ("ipv6: make lookups simpler and faster")
>> this no longer holds and the actual value of sk_v6_rcv_saddr was
>> no longer being migrated.
>>
>> With this patch, the lksctp test suite passes again for IPv6.
>>
>> Fixes: efe4208f47f9 ("ipv6: make lookups simpler and faster")
>> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
>> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
>> Cc: Eric Dumazet <eric.dumazet@gmail.com>
>> ---
>>   net/sctp/ipv6.c | 1 +
>>   1 file changed, 1 insertion(+)
>>
>> diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
>> index 7567e6f..be08592 100644
>> --- a/net/sctp/ipv6.c
>> +++ b/net/sctp/ipv6.c
>> @@ -661,6 +661,7 @@ static struct sock *sctp_v6_create_accept_sk(struct sock *sk,
>>   	 * and getpeername().
>>   	 */
>>   	sctp_v6_to_sk_daddr(&asoc->peer.primary_addr, newsk);
>> +	newsk->sk_v6_rcv_saddr = sk->sk_v6_rcv_saddr;
>>
>>   	sk_refcnt_debug_inc(newsk);
>>
>>
>
> This fixes the issue for the accept() case, but the bug is still there
> in the peeloff case.
>
> I think you should make sctp_copy_sock() use sock_copy() for now.  It
> looks like it will catch all the cases.

I tried that and my machine froze when running lksctp. ;-)

Currently a bit busy, so I need to get back to this later tonight.

> We can then look at possibly getting rid of sctp_copy_sock() for net-next.
>
> -vlad
