From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH Resend] af_unix: dont send SCM_CREDENTIAL when dest
 socket is NULL
Date: Tue, 26 Mar 2013 12:34:45 -0400 (EDT)
Message-ID: <20130326.123445.810551732450695869.davem@davemloft.net>
References: <51510FAC.5090605@huawei.com>
	<1364272687.1716.12.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dingtianhong@huawei.com, edumazet@google.com, lizefan@huawei.com,
	huxinwei@huawei.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40677 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934635Ab3CZQet (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 12:34:49 -0400
In-Reply-To: <1364272687.1716.12.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 25 Mar 2013 21:38:07 -0700

> On Tue, 2013-03-26 at 11:02 +0800, dingtianhong wrote:
>> SCM_SCREDENTIALS should apply to write() syscalls only either source or destination
>> socket asserted SOCK_PASSCRED. The original implememtation in maybe_add_creds is wrong,
>> and breaks several LSB testcases ( i.e. /tset/LSB.os/netowkr/recvfrom/T.recvfrom).
>> 
>> Origionally-authored-by: Karel Srot <ksrot@redhat.com>
>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>> ---
>>  net/unix/af_unix.c | 4 ++--
>>  1 file changed, 2 insertions(+), 2 deletions(-)
>> 
>> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
>> index 51be64f..99189fd 100644
>> --- a/net/unix/af_unix.c
>> +++ b/net/unix/af_unix.c
>> @@ -1413,8 +1413,8 @@ static void maybe_add_creds(struct sk_buff *skb, const struct socket *sock,
>>  	if (UNIXCB(skb).cred)
>>  		return;
>>  	if (test_bit(SOCK_PASSCRED, &sock->flags) ||
>> -	    !other->sk_socket ||
>> -	    test_bit(SOCK_PASSCRED, &other->sk_socket->flags)) {
>> +	    (other->sk_socket &&
>> +	    test_bit(SOCK_PASSCRED, &other->sk_socket->flags))) {
>>  		UNIXCB(skb).pid  = get_pid(task_tgid(current));
>>  		UNIXCB(skb).cred = get_current_cred();
>>  	}
> 
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable.

 
