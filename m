From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 0/4] New interface for memory accounting (take 1)
Date: Mon, 31 Dec 2007 16:17:37 +0100
Message-ID: <47790811.9080004@cosmosbay.com>
References: <47775B25.7020401@redhat.com> <20071230.233413.117211235.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050401020704020509010701"
Cc: haoki@redhat.com, herbert@gondor.apana.org.au,
	vladislav.yasevich@hp.com, netdev@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net, tyasui@redhat.com,
	mhiramat@redhat.com, satoshi.oshima.fk@hitachi.com,
	billfink@mindspring.com, andi@firstfloor.org, johnpol@2ka.mipt.ru,
	shemminger@linux-foundation.org, yoshfuji@linux-ipv6.org,
	yumiko.sugita.yf@hitachi.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:36905 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752144AbXLaPUF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 10:20:05 -0500
In-Reply-To: <20071230.233413.117211235.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050401020704020509010701
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit

David Miller a écrit :
> From: Hideo AOKI <haoki@redhat.com>
> Date: Sun, 30 Dec 2007 03:47:33 -0500
> 
>> Hello,
>>
>> This patch set introduces new memory accounting interface.
>> Current interface is written for stream protocols only.
>> To enable memory accounting in other protocols (e.g. UDP),
>> I enhanced the interface and updated TCP and SCTP memory
>> accounting.
>>
>> The patch set consists of the following 4 patches.
>>
>> [1/4] introducing new memory accounting interface
>> [2/4] adding memory accounting points to consolidate functions
>> [3/4] updating TCP to use new interface
>> [4/4] updating SCTP to use new interface
>>
>> The patch set was tested on net-2.6.25 tree.
> 
> I like this work very much and will add this to net-2.6.25
> But I will have to combine it all into one patch.
> 
> You cannot have one patch which breaks the build in any way.  All of
> the kernel must build properly after each patch in your patchset is
> applied.
> 
> Since patch 1 renames all of the sk_stream_*() functions, TCP and SCTP
> stop building.
> 
> We enforce this rule, otherwise when users try to use "git bisect" to
> find out where regressions are added, they will get stuck in places
> like this where the tree will not build due to such careless
> changesets.

Hi David

Could you add the following patch, because it apparently was lost
during the battle :)

Thank you

[PATCH] use SK_MEM_QUANTUM_SHIFT in __sk_mem_reclaim()

Avoid an expensive divide (as done in commit 
18030477e70a826b91608aee40a987bbd368fec6 but lost in commit 
23821d2653111d20e75472c8c5003df1a55309a8)


Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

--------------050401020704020509010701
Content-Type: text/plain;
 name="__sk_mem_reclaim.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="__sk_mem_reclaim.patch"

diff --git a/net/core/sock.c b/net/core/sock.c
index 8c184c4..3804e7d 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1476,7 +1476,7 @@ void __sk_mem_reclaim(struct sock *sk)
 {
 	struct proto *prot = sk->sk_prot;
 
-	atomic_sub(sk->sk_forward_alloc / SK_MEM_QUANTUM,
+	atomic_sub(sk->sk_forward_alloc >> SK_MEM_QUANTUM_SHIFT,
 		   prot->memory_allocated);
 	sk->sk_forward_alloc &= SK_MEM_QUANTUM - 1;
 

--------------050401020704020509010701--
