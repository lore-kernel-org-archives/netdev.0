From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] liquidio: store the L4 hash of rx packets in
 skb
Date: Mon, 09 Jan 2017 13:56:21 -0500 (EST)
Message-ID: <20170109.135621.1633543054179916746.davem@davemloft.net>
References: <20170107005542.GA16278@felix.cavium.com>
        <20170108.170941.1437038681712014840.davem@davemloft.net>
        <20170109184505.GA8756@felix.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47070 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1163391AbdAIS4X (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 13:56:23 -0500
In-Reply-To: <20170109184505.GA8756@felix.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Mon, 9 Jan 2017 10:45:05 -0800

> David Miller <davem@davemloft.net> wrote on Sun [2017-Jan-08 17:09:41 -0500]:
>> From: Felix Manlunas <felix.manlunas@cavium.com>
>> Date: Fri, 6 Jan 2017 16:55:42 -0800
>> 
>> >  
>> > +		if (rh->r_dh.has_hash) {
>> > +			u32 hash = be32_to_cpu(*(u32 *)(skb->data + r_dh_off));
>> 
>> Is the checksum defined to be in the first 4-bytes of the 8-byte DHLEN unit,
>> or the second 4-bytes?  Is the answer to this question endian-dependent?
> 
> The hash is always in the first 4-bytes.  The location of the hash is endian
> independent.  The hash itself (in its original form) is big endian.

Thanks for explaining.

Please fix the SPARSE issue Eric Dumazet mentioned.
