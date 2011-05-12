From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 02/15] ehea: Update multiqueue support
Date: Thu, 12 May 2011 03:57:04 +0100
Message-ID: <1305169024.4065.384.camel@localhost>
References: <20110512005213.897432612@samba.org>
	 <20110512005622.681433781@samba.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: leitao@linux.vnet.ibm.com, michael@ellerman.id.au,
	jesse@kernel.org, netdev@vger.kernel.org
To: Anton Blanchard <anton@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:12595 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751850Ab1ELC5I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 May 2011 22:57:08 -0400
In-Reply-To: <20110512005622.681433781@samba.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-05-12 at 10:52 +1000, Anton Blanchard wrote:
> The ehea driver had some multiqueue support but was missing the last
> few years of networking stack improvements:
[...]
> --- linux-net.orig/drivers/net/ehea/ehea_main.c	2011-05-12 07:47:48.840103988 +1000
> +++ linux-net/drivers/net/ehea/ehea_main.c	2011-05-12 07:47:49.640116670 +1000
> @@ -60,7 +60,7 @@ static int rq1_entries = EHEA_DEF_ENTRIE
>  static int rq2_entries = EHEA_DEF_ENTRIES_RQ2;
>  static int rq3_entries = EHEA_DEF_ENTRIES_RQ3;
>  static int sq_entries = EHEA_DEF_ENTRIES_SQ;
> -static int use_mcs;
> +static int use_mcs = 1;
>  static int use_lro;
>  static int lro_max_aggr = EHEA_LRO_MAX_AGGR;
>  static int num_tx_qps = EHEA_NUM_TX_QP;
> @@ -93,7 +93,7 @@ MODULE_PARM_DESC(rq1_entries, "Number of
>  MODULE_PARM_DESC(sq_entries, " Number of entries for the Send Queue  "
>  		 "[2^x - 1], x = [6..14]. Default = "
>  		 __MODULE_STRING(EHEA_DEF_ENTRIES_SQ) ")");
> -MODULE_PARM_DESC(use_mcs, " 0:NAPI, 1:Multiple receive queues, Default = 0 ");
> +MODULE_PARM_DESC(use_mcs, " 0:NAPI, 1:Multiple receive queues, Default = 1 ");
[...]

You're using NAPI whether or not there are multiple receive queues, so
this description is wrong.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

