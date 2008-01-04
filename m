From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [ICMP]: Avoid sparse warnings in net/ipv4/icmp.c
Date: Fri, 04 Jan 2008 06:34:28 +0100
Message-ID: <477DC564.4050008@cosmosbay.com>
References: <477DC304.40508@cosmosbay.com> <20080103.212610.263261100.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030503070402080508030707"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:35959 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751755AbYADFek (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2008 00:34:40 -0500
In-Reply-To: <20080103.212610.263261100.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030503070402080508030707
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit

David Miller a écrit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Fri, 04 Jan 2008 06:24:20 +0100
> 
>>    CHECK   net/ipv4/icmp.c
>> net/ipv4/icmp.c:249:13: warning: context imbalance in 'icmp_xmit_unlock' - 
>> unexpected unlock
>> net/ipv4/icmp.c:376:13: warning: context imbalance in 'icmp_reply' - different 
>> lock contexts for basic block
>> net/ipv4/icmp.c:430:6: warning: context imbalance in 'icmp_send' - different 
>> lock contexts for basic block
>>
>> Solution is to declare icmp_xmit_unlock() as __inline__ (similar with 
>> icmp_xmit_lock())
> 
> Please use "inline" instead of "__inline__".  If other stuff
> uses __inline__ in that file, feel free to fix it up too.
> 

You are right, here is the updated version

Thank you

[ICMP]: Avoid sparse warnings in net/ipv4/icmp.c

   CHECK   net/ipv4/icmp.c
net/ipv4/icmp.c:249:13: warning: context imbalance in 'icmp_xmit_unlock' - 
unexpected unlock
net/ipv4/icmp.c:376:13: warning: context imbalance in 'icmp_reply' - different 
lock contexts for basic block
net/ipv4/icmp.c:430:6: warning: context imbalance in 'icmp_send' - different 
lock contexts for basic block

Solution is to declare both icmp_xmit_lock() and icmp_xmit_unlock() as inline

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

  net/ipv4/icmp.c |    4 ++--
  1 files changed, 2 insertions(+), 2 deletions(-)


--------------030503070402080508030707
Content-Type: text/plain;
 name="icmp.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="icmp.patch"

diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index fc66c8a..1c256ff 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -232,7 +232,7 @@ static const struct icmp_control icmp_pointers[NR_ICMP_TYPES+1];
 static DEFINE_PER_CPU(struct sock *, __icmp_sock) = NULL;
 #define icmp_sock	__get_cpu_var(__icmp_sock)
 
-static __inline__ int icmp_xmit_lock(void)
+static inline int icmp_xmit_lock(void)
 {
 	local_bh_disable();
 
@@ -246,7 +246,7 @@ static __inline__ int icmp_xmit_lock(void)
 	return 0;
 }
 
-static void icmp_xmit_unlock(void)
+static inline void icmp_xmit_unlock(void)
 {
 	spin_unlock_bh(&icmp_sock->sk_lock.slock);
 }

--------------030503070402080508030707--
