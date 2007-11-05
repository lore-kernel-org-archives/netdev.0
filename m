From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH 0/4] NET : struct proto diet
Date: Mon, 05 Nov 2007 18:52:32 +0100
Message-ID: <472F5860.4010607@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2f.orange.fr ([80.12.242.152]:51746 "EHLO smtp2f.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752096AbXKERwk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Nov 2007 12:52:40 -0500
Received: from me-wanadoo.net (localhost [127.0.0.1])
	by mwinf2f26.orange.fr (SMTP Server) with ESMTP id 7144F70000AC
	for <netdev@vger.kernel.org>; Mon,  5 Nov 2007 18:52:38 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi

After reading David's machines have NR_CPUS set to 4096, I realized how 
fat was 'struct proto', since it uses a stats[NR_CPUS] field to keep 
track of inuse sockets per protocol.

With NR_CPUS = 4096, this means we allocate 4096*SMP_CACHE_BYTES bytes 
per 'struct proto'.
As these structures are static (data section of kernel), this grows data 
kernel section by 256 KB per protocol.

This patch series does some cleanup and optimization.

[PATCH 1/4] NET : defines an infrastructure to keep 'inuse' changes in 
an efficent SMP/NUMA way.
[PATCH 2/4] NET : makes ipv4 use the  {DEFINE|REF}_PROTO_INUSE 
infrastructure
[PATCH 3/4] NET : makes ipv6 use the  {DEFINE|REF}_PROTO_INUSE 
infrastructure
[PATCH 4/4] NET : makes sctp use the  {DEFINE|REF}_PROTO_INUSE 
infrastructure


Thank you
Eric



