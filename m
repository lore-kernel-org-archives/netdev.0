From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [net-next PATCH 0/6] ipv4/fib_trie: Cleanups to prepare for introduction
 of key vector
Date: Wed, 04 Mar 2015 10:22:44 -0800
Message-ID: <54F74D74.1050002@redhat.com>
References: <20150302212637.1490.33609.stgit@ahduyck-vm-fedora20>	<20150304.001640.1653151786060996185.davem@davemloft.net>	<54F71BEF.5030706@redhat.com> <20150304.125327.2002716390225095168.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34747 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758699AbbCDSWr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Mar 2015 13:22:47 -0500
In-Reply-To: <20150304.125327.2002716390225095168.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 03/04/2015 09:53 AM, David Miller wrote:
> From: Alexander Duyck <alexander.h.duyck@redhat.com>
> Date: Wed, 04 Mar 2015 06:51:27 -0800
>
>> If bits can be 32 then idx should be an unsigned long which is 64
>> bits.
> unsigned long is 32-bit on 32-bit platforms

Right, but if unsigned long is 32 bits then usually a pointer is as 
well.  As a result we wouldn't be able to access the upper bits of a 
node with bits == 32 since the size of the tnode would be over 4 * 2^32.

The general idea is the vmalloc should fail when we attempt to allocate 
a bits == 32 tnode on a system w/ only 32b longs.  Then again I think we 
will probably cause a memory corruption on a 32b system since we are 
probably overflowing size_t on the allocation if bits ==32.  I'll have 
to take a look as I believe we are using the offsetof macro and I am not 
sure how that handles a 64b address on a 32b system.

- Alex
