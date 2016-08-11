From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH 04/21] net: thunderx: Set queue count based on number of
 CPUs
Date: Thu, 11 Aug 2016 09:36:10 +0000
Message-ID: <CO2PR11MB008837F849AB5891E076DF41971E0@CO2PR11MB0088.namprd11.prod.outlook.com>
References: <1470811373-28277-1-git-send-email-sunil.kovvuri@gmail.com>
 <1470811373-28277-5-git-send-email-sunil.kovvuri@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	Sunil Goutham <sgoutham@cavium.com>
To: "sunil.kovvuri@gmail.com" <sunil.kovvuri@gmail.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0138.outbound.protection.outlook.com ([104.47.41.138]:33504
	"EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933094AbcHKJgP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2016 05:36:15 -0400
In-Reply-To: <1470811373-28277-5-git-send-email-sunil.kovvuri@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 81xx has only 4 CPUs, so it doesn't make sense to initialize entire Qset i.e 8
> queues by default. Made changes to queue initialization to init queues equal to
> number of CPUs or
> 8 queues whichever is lesser. Also this will be applicable to VMs with VNIC VF
> attached and having less VCPUs
...
> -	qcount = MAX_CMP_QUEUES_PER_QS;
> +	qcount = min_t(int, MAX_CMP_QUEUES_PER_QS, num_online_cpus());

We have netif_get_num_default_rss_queues() which does this.
