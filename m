From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: Add sysctl knob to control early socket demux
Date: Fri, 22 Jun 2012 23:03:09 -0700 (PDT)
Message-ID: <20120622.230309.840882929065842528.davem@davemloft.net>
References: <20120621235011.29846.29715.stgit@gitlad.jf.intel.com>
	<20120622.171509.1112294083000632011.davem@davemloft.net>
	<1340430326.4604.11946.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, edumazet@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40043 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751799Ab2FWGDK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jun 2012 02:03:10 -0400
In-Reply-To: <1340430326.4604.11946.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 23 Jun 2012 07:45:26 +0200

> On Fri, 2012-06-22 at 17:15 -0700, David Miller wrote:
> 
>> I applied this for now, making a minor change to move the local
>> variables down into the new basic block you created.
>> 
> 
> Hmm, sorry to come late, but you left NET_IPV4_EARLY_DEMUX=126 sysctl,
> while this is deprecated way...

Thanks for catching this:

--------------------
[PATCH] ipv4: Don't add deprecated new binary sysctl value.

Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/sysctl.h |    1 -
 kernel/sysctl_binary.c |    2 --
 2 files changed, 3 deletions(-)

diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 20825e5..c34b4c8 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -425,7 +425,6 @@ enum
 	NET_TCP_ALLOWED_CONG_CONTROL=123,
 	NET_TCP_MAX_SSTHRESH=124,
 	NET_TCP_FRTO_RESPONSE=125,
-	NET_IPV4_EARLY_DEMUX=126,
 };
 
 enum {
diff --git a/kernel/sysctl_binary.c b/kernel/sysctl_binary.c
index 6a3cf82..a650694 100644
--- a/kernel/sysctl_binary.c
+++ b/kernel/sysctl_binary.c
@@ -415,8 +415,6 @@ static const struct bin_table bin_net_ipv4_table[] = {
 	{ CTL_INT,	NET_IPV4_IPFRAG_SECRET_INTERVAL,	"ipfrag_secret_interval" },
 	/* NET_IPV4_IPFRAG_MAX_DIST "ipfrag_max_dist" no longer used */
 
-	{ CTL_INT,	NET_IPV4_EARLY_DEMUX,			"ip_early_demux" },
-
 	{ CTL_INT,	2088 /* NET_IPQ_QMAX */,		"ip_queue_maxlen" },
 
 	/* NET_TCP_DEFAULT_WIN_SCALE unused */
-- 
1.7.10.2
