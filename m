From: Josh Hunt <johunt@akamai.com>
Subject: Re: [PATCH] fix tcp fin memory accounting
Date: Thu, 23 Apr 2015 08:48:17 -0500
Message-ID: <5538F821.6070503@akamai.com>
References: <1426807170-19258-1-git-send-email-johunt@akamai.com>		<20150320.132029.103306583158863864.davem@davemloft.net>		<550C5A98.5040305@akamai.com>	 <20150324.021050.384709317309031128.davem@davemloft.net>	 <55110009.4020706@akamai.com> <1429661349.18561.23.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	edumazet@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay08.akamai.com ([96.6.114.112]:12314 "EHLO
	prod-mail-xrelay08.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752754AbbDWNzC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2015 09:55:02 -0400
In-Reply-To: <1429661349.18561.23.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/21/2015 07:09 PM, Eric Dumazet wrote:
>
> Note that this patch adds a deadlock possibility in some stress
> situations.
>
> If a process owning some tcp socket dies, and tcp_mem[2] is already hit,
> all sk_stream_alloc_skb() can return NULL and we loop in tcp_send_fin(),
> making no progress because we can not free any tcp memory.

Ugh. Thanks for fixing this Eric!

Josh
