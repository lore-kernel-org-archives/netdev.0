From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH v2] Receive Packet Steering
Date: Fri, 17 Jul 2009 12:59:31 -0700
Message-ID: <65634d660907171259l2a3a31fel549176274201bd66@mail.gmail.com>
References: <65634d660907141628g671812f9t4219cc8b6a493425@mail.gmail.com>
	 <20090716.194846.58845712.davem@davemloft.net>
	 <65634d660907171105s4989758ah533203d107924b6a@mail.gmail.com>
	 <20090717.110840.128146209.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:19100 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752126AbZGQT7g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2009 15:59:36 -0400
Received: from spaceape13.eur.corp.google.com (spaceape13.eur.corp.google.com [172.28.16.147])
	by smtp-out.google.com with ESMTP id n6HJxYBr018483
	for <netdev@vger.kernel.org>; Fri, 17 Jul 2009 20:59:34 +0100
Received: from qw-out-1920.google.com (qwf5.prod.google.com [10.241.194.69])
	by spaceape13.eur.corp.google.com with ESMTP id n6HJxV2Y018109
	for <netdev@vger.kernel.org>; Fri, 17 Jul 2009 12:59:32 -0700
Received: by qw-out-1920.google.com with SMTP id 5so408894qwf.50
        for <netdev@vger.kernel.org>; Fri, 17 Jul 2009 12:59:31 -0700 (PDT)
In-Reply-To: <20090717.110840.128146209.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 17, 2009 at 11:08 AM, David Miller<davem@davemloft.net> wrote:
> From: Tom Herbert <therbert@google.com>
> Date: Fri, 17 Jul 2009 11:05:58 -0700
>
>> The advantage is that Toeplitz, or any reasonable device provided
>> hash, allows packet steering to be done without taking any cache
>> misses on the packet itself.  In particular, this helps with a NIC
>> that just provides Toeplitz hash (without multiQ),
>
> Good point.
>
> Depending upon the cache line size, however, we might have
> at least the IP header in the cpu cache at this point since
> eth_type_trans() had to pull in the entire ethernet header
> underneath.
>

eth_type_trans does not need to even be called assuming that the
packet type information can be inferred from the RX descriptor.  We
are doing steering completely based on contents of the RX descriptor.
