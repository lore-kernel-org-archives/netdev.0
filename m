From: David Miller <davem@davemloft.net>
Subject: Re: [Eulerkernel] [PATCH] af_unix: dont send SCM_CREDENTIAL when
 dest socket is NULL
Date: Mon, 25 Mar 2013 13:12:32 -0400 (EDT)
Message-ID: <20130325.131232.1340802984347600866.davem@davemloft.net>
References: <515026DA.7050306@huawei.com>
	<1364220269.29473.13.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dingtianhong@huawei.com, edumazet@google.com,
	netdev@vger.kernel.org, lizefan@huawei.com, huxinwei@huawei.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53960 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758715Ab3CYRMf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Mar 2013 13:12:35 -0400
In-Reply-To: <1364220269.29473.13.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 25 Mar 2013 07:04:29 -0700

> On Mon, 2013-03-25 at 18:28 +0800, dingtianhong wrote:
>> SCM_SCREDENTIALS should apply to write() syscalls only either source or destination
>> socket asserted SOCK_PASSCRED. The original implememtation in maybe_add_creds is wrong,
>> and breaks several LSB testcases ( i.e. /tset/LSB.os/netowkr/recvfrom/T.recvfrom).
>> 
>> Origionally-authored-by: Karel Srot <ksrot@redhat.com>
>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>> ---
>>    net/unix/af_unix.c | 4 ++--
>>    1 file changed, 2 insertions(+), 2 deletions(-)
>> 
>> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
>> index 51be64f..99189fd 100644
>> --- a/net/unix/af_unix.c
>> +++ b/net/unix/af_unix.c
>> @@ -1413,8 +1413,8 @@ static void maybe_add_creds(struct sk_buff *skb, const struct socket *sock,
>>           if (UNIXCB(skb).cred)
>>                   return;
>>           if (test_bit(SOCK_PASSCRED, &sock->flags) ||
>> -           !other->sk_socket ||
>> -           test_bit(SOCK_PASSCRED, &other->sk_socket->flags)) {
>> +           (other->sk_socket &&
>> +           test_bit(SOCK_PASSCRED, &other->sk_socket->flags))) {
>>                   UNIXCB(skb).pid  = get_pid(task_tgid(current));
>>                   UNIXCB(skb).cred = get_current_cred();
>>           }
> 
> I am not sure why adding credentials if other->sk_socket is NULL could
> break an application ?
> 
> This was the case before commit introducing this code.
> 
> Anyway patch looks fine
> 
> Acked-by: Eric Dumazet <edumazet@google.com>

This patch is massively whitespace damaged, and therefore completely
unusable.

Please fix this, and only resubmit this patch when you can successfully
email the patch to yourself and apply it successfully.
