From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: Fix bugs in "Whether sock accept queue is full" checking
Date: Thu, 22 Feb 2007 13:09:46 -0500
Message-ID: <45DDDC6A.6080205@hp.com>
References: <1171470657.7414.15.camel@LINE> <20070222.031310.85405859.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: weid@np.css.fujitsu.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:56778 "EHLO atlrel7.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751281AbXBVSJs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Feb 2007 13:09:48 -0500
In-Reply-To: <20070222.031310.85405859.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: weidong <weid@np.css.fujitsu.com>
> Date: Wed, 14 Feb 2007 11:30:57 -0500
> 
>> 	when I use linux TCP socket, and find there is a bug in function
>> sk_acceptq_is_full(). 
>  ...
>> Consider an example:
>>
>>  After listen(sockfd, 1) system call, sk->sk_max_ack_backlog is set to
>> 1. As we know, sk->sk_ack_backlog is initialized to 0. Assuming accept()
>> system call is not invoked now.
>>
>> 1. 1st connection comes. invoke sk_acceptq_is_full(). sk-
>>> sk_ack_backlog=0 sk->sk_max_ack_backlog=1, function return 0 accept
>> this connection. Increase the sk->sk_ack_backlog
>> 2. 2nd connection comes. invoke sk_acceptq_is_full(). sk-
>>> sk_ack_backlog=1 sk->sk_max_ack_backlog=1, function return 0 accept
>> this connection. Increase the sk->sk_ack_backlog
>> 3. 3rd connection comes. invoke sk_acceptq_is_full(). sk-
>>> sk_ack_backlog=2 sk->sk_max_ack_backlog=1, function return 1. Refuse
>> this connection.
>>
>> I think it has bugs. after listen system call. sk->sk_max_ack_backlog=1
>> but now it can accept 2 connections. The following patch can fix this
>> problem.
>>
>> signed-off-by: Wei Dong <weid@np.css.fujitsu.com>
> 
> Thank you very much for the detailed analysis and fix.
> 
> Actually, this bug exists all over the tree I believe, not just
> in TCP.  I would like to audit all uses of sk_ack_backlog and
> sk_max_ack_backlog before applying your patch, so please give
> me some time to perform a quick audit.
> 
> Thank you.

Hi David

I can confirm the same problem exists in SCTP because of the use of sk_acceptq_is_full().

-vlad
