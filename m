From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: [PATCH] net core: optimize netdev_create_hash()
Date: Sat, 16 Mar 2013 09:19:42 +0800
Message-ID: <20130316011942.GC5531@weiyang.vnet.ibm.com>
References: <1363365131-7906-1-git-send-email-weiyang@linux.vnet.ibm.com>
 <20130315.173930.609483181280202005.davem@davemloft.net>
 <20130316000051.GA5941@richard.(null)>
Reply-To: Wei Yang <weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp05.au.ibm.com ([202.81.31.147]:44345 "EHLO
	e23smtp05.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754081Ab3CPBUU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Mar 2013 21:20:20 -0400
Received: from /spool/local
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <weiyang@linux.vnet.ibm.com>;
	Sat, 16 Mar 2013 11:15:58 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 87BD5357804A
	for <netdev@vger.kernel.org>; Sat, 16 Mar 2013 12:20:14 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2G1Jeq86750498
	for <netdev@vger.kernel.org>; Sat, 16 Mar 2013 12:19:41 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2G1Jiwv000996
	for <netdev@vger.kernel.org>; Sat, 16 Mar 2013 12:19:44 +1100
Content-Disposition: inline
In-Reply-To: <20130316000051.GA5941@richard.(null)>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[resend for syntax error in Message-ID]

David, 

Thanks for pointing out the error, it really helps.

I guess last mail is still blocked by the mail server, so I resend it.
Hope it works now.

On Sat, Mar 16, 2013 at 08:00:51AM +0800, Wei Yang wrote:
On Fri, Mar 15, 2013 at 05:39:30PM -0400, David Miller wrote:
>From: Wei Yang <weiyang@linux.vnet.ibm.com>
>Date: Sat, 16 Mar 2013 00:32:11 +0800
>
>> netdev_create_hash() is divded into two steps:
>> 1. allocate space for hash_head
>> 2. initialize hash_head->first to NULL for each hash_head
>> 
>> This patch merge the two steps into one step.
>> 
>> When allocating the space for hash_head, it will use kzalloc() instead of
>> kmalloc(). Then hash_head->first is set to NULL during the allocation step,
>> which means it is not necessary to call INIT_HLIST_HEAD() for each hash_head.
>> 
>> This will:
>> 1. reduce the code size
>> 2. reduce the run time of iteration on initializing hash_head array
>
>Please do not ever post changes like this.
>
>This makes assumtions about the list head implementation that
>we should not make.  If someone adds a debugging facility that
>causes lists to be initialized differently, it will be broken
>for this hash table now.

Yes, this is based on the assumtion. 
And agree, this will break the behavior.

>
>The reason the abstractions exist is so that people do not
>do things like you are trying to do.
>
>If you want to add an interface in the generic list facilities which
>performs this simplifcation, fine.  Implement it and post such a
>suggestion to linux-kernel, and then once such a facility is present
>in Linus's tree we can start using it in the networkng code.

Thanks for your suggestion and kindness.

-- 
Richard Yang
Help you, Help me

-- 
Richard Yang
Help you, Help me
