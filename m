From: Pavel Emelianov <xemul@sw.ru>
Subject: Re: [PATCH] Consolidate udp hash calculations
Date: Mon, 07 May 2007 11:07:15 +0400
Message-ID: <463ED023.4060109@sw.ru>
References: <463B4878.4060902@sw.ru> <20070504.123909.88476080.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:1967 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754077AbXEGHC0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 May 2007 03:02:26 -0400
In-Reply-To: <20070504.123909.88476080.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Pavel Emelianov <xemul@sw.ru>
> Date: Fri, 04 May 2007 18:51:36 +0400
> 
>> Make access to udphash/udplitehash symmetrical to inet hashes.
>>
>> This may also help network namespaces, since they tend to use
>> one hash for different namespaces by selecting the hash chain
>> depending on a hash value and the namespace.
>>
>> Signed-off-by: Pavel Emelianov <xemul@openvz.org>
> 
> This is not the "UDP Hash Function", it is a mask to bring
> the hash value modulo of the hash table size.
> 
> So your function name is misleading and makes the code
> even worse.
> 
> I'm also not so sure this cleanup really adds any clarity,
> even with a proper function name.

The same is applicable to inet_lhashfn and inet_bhashfn, but they
are called hashfn-s and do exist in kernel. This hashfn will make
things look similar.

> I can only assume you wish to do something with the UDP hash table
> sizes, and therefore only want to have a need to touch one function.

You are right, I have told that this must help network namespaces,
by making the hash differ depending on the namespace passed.
