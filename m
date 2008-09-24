From: Corey Minyard <minyard@acm.org>
Subject: Re: [PATCH 1/1] Use RCU for the UDP hash lock
Date: Wed, 24 Sep 2008 15:46:20 -0500
Message-ID: <48DAA71C.5030000@acm.org>
References: <20080924172827.GA1573@minyard.local>
 <20080924124006.6bb41b49@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms044pub.verizon.net ([206.46.252.44]:44449 "EHLO
	vms044pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752587AbYIXUq6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2008 16:46:58 -0400
In-reply-to: <20080924124006.6bb41b49@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
>   
>>  
>>  static inline void udp_lib_unhash(struct sock *sk)
>>  {
>> -	write_lock_bh(&udp_hash_lock);
>> -	if (sk_del_node_init(sk)) {
>> +	spin_lock_bh(&udp_hash_wlock);
>> +	if (sk_del_node_rcu(sk)) {
>>  		inet_sk(sk)->num = 0;
>>  		sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
>>  	}
>> -	write_unlock_bh(&udp_hash_lock);
>> +	spin_unlock_bh(&udp_hash_wlock);
>> +	synchronize_sched();
>>     
>
> Could this be synchronize_rcu? You are using rcu_read_lock() protected sections.
>   
I meant to comment on that.  I wasn't sure which to use, so I chose the 
more conservative approach.  synchronize_rcu() might be appropriate.

-corey

