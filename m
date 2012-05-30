From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH] l2tp: fix oops in L2TP IP sockets for connect() AF_UNSPEC
 case
Date: Wed, 30 May 2012 09:53:54 +0100
Message-ID: <4FC5E022.6020609@katalix.com>
References: <1338298242-22261-1-git-send-email-jchapman@katalix.com> <20120529.172008.875375243438479060.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, levinsasha928@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:35858 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932272Ab2E3Ix6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 May 2012 04:53:58 -0400
In-Reply-To: <20120529.172008.875375243438479060.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 29/05/12 22:20, David Miller wrote:
> From: James Chapman <jchapman@katalix.com>
> Date: Tue, 29 May 2012 14:30:42 +0100
> 
>> An application may call connect() to disconnect a socket using an
>> address with family AF_UNSPEC. The L2TP IP sockets were not handling
>> this case when the socket is not bound and an attempt to connect()
>> using AF_UNSPEC in such cases would result in an oops. This patch
>> addresses the problem by protecting the sk_prot->disconnect() call
>> against trying to unhash the socket before it is bound.
>>
>> The L2TP IPv4 and IPv6 sockets have the same problem. Both are fixed
>> by this patch.
>>
>> The patch also adds more checks that the sockaddr supplied to bind()
>> and connect() calls is valid.
>>
>>  RIP: 0010:[<ffffffff82e133b0>]  [<ffffffff82e133b0>] inet_unhash+0x50/0xd0
>>  RSP: 0018:ffff88001989be28  EFLAGS: 00010293
>>  Stack:
>>   ffff8800407a8000 0000000000000000 ffff88001989be78 ffffffff82e3a249
>>   ffffffff82e3a050 ffff88001989bec8 ffff88001989be88 ffff8800407a8000
>>   0000000000000010 ffff88001989bec8 ffff88001989bea8 ffffffff82e42639
>>  Call Trace:
>>  [<ffffffff82e3a249>] udp_disconnect+0x1f9/0x290
>>  [<ffffffff82e42639>] inet_dgram_connect+0x29/0x80
>>  [<ffffffff82d012fc>] sys_connect+0x9c/0x100
>>
>> Reported-by: Sasha Levin <levinsasha928@gmail.com>
>> Signed-off-by: James Chapman <jchapman@katalix.com>
> 
> Applied and queued up for -stable, thanks James.

The patch doesn't apply to stable due to recent l2tp_ip changes (IPv6
support) already merged. I'll spin a version for -stable.


-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development
