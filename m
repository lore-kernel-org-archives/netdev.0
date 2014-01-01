From: Yuval Mintz <yuvalmin@broadcom.com>
Subject: RE: [PATCH net-next 2/2] net/mlx4: Revert "mlx4: set maximal number
 of default RSS queues"
Date: Wed, 1 Jan 2014 18:46:42 +0000
Message-ID: <979A8436335E3744ADCD3A9F2A2B68A52AF21A1A@SJEXCHMB10.corp.ad.broadcom.com>
References: <1388581537-4810-1-git-send-email-amirv@mellanox.com>
 <1388581537-4810-3-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Ido Shamay <idos@mellanox.com>
To: Amir Vadai <amirv@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:51425 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754588AbaAASqo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jan 2014 13:46:44 -0500
In-Reply-To: <1388581537-4810-3-git-send-email-amirv@mellanox.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Eugenia Emantayev <eugenia@mellanox.com>
> 
> This reverts commit 90b1ebe "mlx4: set maximal number of default RSS
> queues".
> Limiting the number of receive rings to default (8) reduces overall
> packet rate by 15% in multiple TCP streams application:
> 
>           Packet rate
> 8  rings  967691
> 16 rings  1142070
> 
> Results were obtained using netperf:
> 
> S=200 ; ( for i in $(seq 1 $S) ; do ( \
>   netperf -H 11.7.13.55 -t TCP_RR -l 30 &) ; \
>   wait ; done | grep "1        1" | awk '{SUM+=$6} END {print SUM}' )

Seems odd - well, to be more exact, nothing is odd about the results;
the whole notion of the original patch was to set an upper limit on the
number of  interrupt vectors multi-queue devices ask by default, not
to improve the default performance.

If you believe this is a better default (or some relaxation will be, 
e.g.,  16 instead of 8),  why not set it as default for ALL multi-queue 
networking drivers?

Thanks,
Yuval
