From: Laszlo Attila Toth <panther@balabit.hu>
Subject: Re: [PATCH] fix build bug in 2.6.30-rc4: xt_socket.c:(.text+0x57780):
 undefined reference to `nf_conntrack_untracked'
Date: Thu, 30 Apr 2009 17:10:50 +0200
Message-ID: <49F9BF7A.4000500@balabit.hu>
References: <20090430075554.GA12204@elte.hu> <20090430.040606.154074536.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu, netdev@vger.kernel.org, shemminger@vyatta.com,
	kaber@trash.net, linux-kernel@vger.kernel.org,
	KOVACS Krisztian <hidden@sch.bme.hu>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from support.balabit.hu ([195.70.41.86]:60983 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756158AbZD3Pcb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Apr 2009 11:32:31 -0400
In-Reply-To: <20090430.040606.154074536.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Ingo is right, this patch is problematic because of the xt_socket code.
The nf_conntrack is not necessary for xt_socket, but it can use 
connection tracking.

The only problematic use case is what Ingo found:

  CONFIG_NF_CONNTRACK=m
  CONFIG_NETFILTER_XT_MATCH_SOCKET=y

The following patch solves it , I'll send it soon in a single letter:

diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 881203c..cb3ad74 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -837,6 +837,7 @@ config NETFILTER_XT_MATCH_SOCKET
         depends on NETFILTER_TPROXY
         depends on NETFILTER_XTABLES
         depends on NETFILTER_ADVANCED
+       depends on !NF_CONNTRACK || NF_CONNTRACK
         select NF_DEFRAG_IPV4
         help
           This option adds a `socket' match, which can be used to match


David Miller wrote:
> From: Ingo Molnar <mingo@elte.hu>
> Date: Thu, 30 Apr 2009 09:55:54 +0200
> 
>>     Revert "netfilter: Kconfig: TProxy doesn't depend on NF_CONNTRACK"
>>     
>>     This reverts commit 4b0706624930dc75c3b0d0df463d89759ef7de29.
> 
> Thanks Ingo, I'll apply this revert soon unless Patrick wants to
> handle it differently.
> 


-- 
Attila

