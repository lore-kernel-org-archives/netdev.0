From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: net-next panic in ovs call to arch_fast_hash2 since e5a2c899
Date: Thu, 13 Nov 2014 21:04:04 -0800
Message-ID: <12872.1415941444@famine>
References: <12086.1415931332@famine> <20141113.214549.1520205472319716774.davem@davemloft.net>
Cc: netdev@vger.kernel.org, discuss@openvswitch.org,
	pshelar@nicira.com, ogerlitz@mellanox.com,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:46646 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751308AbaKNFEP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2014 00:04:15 -0500
In-reply-to: <20141113.214549.1520205472319716774.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	[ adding Hannes to Cc, which I should've done initially ]

David Miller <davem@davemloft.net> wrote:

>From: Jay Vosburgh <jay.vosburgh@canonical.com>
>Date: Thu, 13 Nov 2014 18:15:32 -0800
>
>> 	The "have feature" function, __intel_crc4_2_hash2, does not
>> clobber %r8, and so the call does not panic on a system with
>> X86_FEATURE_XMM4_2, although I'm not sure if that's a deliberate
>> compiler action or just happenstance because __intel_crc4_2_hash2 uses
>> fewer registers than __jhash2.
>
>Perhaps alternative calls can only be used with assembler routines
>that use specific calling conventions, and they therefore generally
>don't work with C functions?

	I don't know the answer to that, but a quick search suggests
that arch_fast_hash and arch_fast_hash2 (both added by commit e5a2c899)
may be the only cases of alternative calls that aren't supplying either
single instructions or assembly language functions.

	From looking at how the alternative calls are implemented (code
patching at boot or module load time from a table stored in a special
section of the object file), I'm skeptical that the compiler could know
what's the right thing to do.

	Hannes, can you shed any light on this?

	-J

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
