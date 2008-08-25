From: Phil Love <love_phil@emc.com>
Subject: Re: [PATCH] tcp: fix tcp header size miscalculation when window scale
 is unused
Date: Mon, 25 Aug 2008 09:30:13 -0700
Message-ID: <48B2DE15.70708@emc.com>
References: <20080823.214013.29359753.davem@davemloft.net>	<396556a20805301217k293e5718h6bbf02bfe069081@europa> <20080824.174544.244704849.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mexforward.lss.emc.com ([128.222.32.20]:30425 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753129AbYHYQaZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2008 12:30:25 -0400
Received: from hop04-l1d11-si04.isus.emc.com (HOP04-L1D11-SI04.isus.emc.com [10.254.111.24])
	by mexforward.lss.emc.com (Switch-3.2.5/Switch-3.1.7) with ESMTP id m7PGULZB001546
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 25 Aug 2008 12:30:22 -0400 (EDT)
Received: from mailhub.lss.emc.com (nagas.lss.emc.com [10.254.144.11]) by hop04-l1d11-si04.isus.emc.com (Tablus Interceptor) for <netdev@vger.kernel.org>; Mon, 25 Aug 2008 11:53:10 -0400
Received: from [128.222.177.178] ([128.222.177.178])
	by mailhub.lss.emc.com (Switch-3.2.5/Switch-3.1.7) with ESMTP id m7PGUJ1x008865
	for <netdev@vger.kernel.org>; Mon, 25 Aug 2008 12:30:20 -0400 (EDT)
In-Reply-To: <20080824.174544.244704849.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here is the patch using Thunderbird, rather than Apple Mail. Hopefully 
it is not mangled this time.

Signed-off-by: Philip Love <love_phil@emc.com>

--- a/net/ipv4/tcp_output.c	2008-08-24 07:44:18.000000000 -0700
+++ b/net/ipv4/tcp_output.c	2008-08-24 07:43:05.000000000 -0700
@@ -468,7 +468,8 @@ static unsigned tcp_syn_options(struct s
  	}
  	if (likely(sysctl_tcp_window_scaling)) {
  		opts->ws = tp->rx_opt.rcv_wscale;
-		size += TCPOLEN_WSCALE_ALIGNED;
+		if(likely(opts->ws))
+			size += TCPOLEN_WSCALE_ALIGNED;
  	}
  	if (likely(sysctl_tcp_sack)) {
  		opts->options |= OPTION_SACK_ADVERTISE;
@@ -509,7 +510,8 @@ static unsigned tcp_synack_options(struc

  	if (likely(ireq->wscale_ok)) {
  		opts->ws = ireq->rcv_wscale;
-		size += TCPOLEN_WSCALE_ALIGNED;
+		if(likely(opts->ws))
+			size += TCPOLEN_WSCALE_ALIGNED;
  	}
  	if (likely(doing_ts)) {
  		opts->options |= OPTION_TS;

