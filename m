From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] INET : removes per bucket rwlock in tcp/dccp ehash table
Date: Sun, 04 Nov 2007 19:15:00 +0100
Message-ID: <472E0C24.9040009@o2.pl>
References: <4729A774.9030409@cosmosbay.com>	<200711040018.15027.ak@suse.de> <20071103.162337.83099185.davem@davemloft.net> <472DAD90.4050709@cosmosbay.com> <472E0857.4080405@o2.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	David Miller <davem@davemloft.net>, ak@suse.de,
	netdev@vger.kernel.org, acme@redhat.com
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.go2.pl ([193.17.41.42]:55775 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753906AbXKDSH2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Nov 2007 13:07:28 -0500
In-Reply-To: <472E0857.4080405@o2.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarek Poplawski wrote, On 11/04/2007 06:58 PM:

> Eric Dumazet wrote, On 11/04/2007 12:31 PM:

...

>> +static inline int inet_ehash_locks_alloc(struct inet_hashinfo *hashinfo)
>> +{

...

>> +	if (sizeof(rwlock_t) != 0) {

...

>> +		for (i = 0; i < size; i++)
>> +			rwlock_init(&hashinfo->ehash_locks[i]);
> 
> 
> This looks better now, but still is doubtful to me: even if it's safe with
> current rwlock implementation, can't we imagine some new debugging or
> statistical code added, which would be called from rwlock_init() without
> using rwlock_t structure? IMHO, if read_lock() etc. are called in such a
> case, rwlock_init() should be done as well.


Of course I mean: if sizeof(rwlock_t) == 0.

 
Jarek P
