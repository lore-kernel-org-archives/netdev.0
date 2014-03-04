From: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCHv3 net-next 03/31] cxgb4: Rectify emitting messages about
 SGE Ingress DMA channels being potentially stuck
Date: Tue, 04 Mar 2014 23:22:12 +0300
Message-ID: <531635F4.9050208@cogentembedded.com>
References: <1393936917-25847-1-git-send-email-hariprasad@chelsio.com>	 <1393936917-25847-4-git-send-email-hariprasad@chelsio.com> <1393955035.20435.40.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org, kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	santosh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>,
	Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1393955035.20435.40.camel@joe-AO722>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello.

On 03/04/2014 08:43 PM, Joe Perches wrote:

>> From: Kumar Sanghvi <kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>

>> Based on original work by Casey Leedom <leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>

> trivial comments:

>> diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c

>> @@ -2031,21 +2041,65 @@ static void sge_rx_timer_cb(unsigned long data)
> []
>> +		if (idma_same_state_cnt[i] < s->idma_1s_thresh) {
>> +			if (s->idma_stalled[i] >= SGE_IDMA_WARN_THRESH)
>> +				CH_WARN(adap, "SGE idma%d, queue%u,resumed after %d sec",

> Missing terminating '\n', probably better as:

> 				CH_WARN(adap, "SGE idma%d, queue%u, resumed after %d sec\n",

>> +		CH_WARN(adap, "SGE idma%u, queue%u, maybe stuck state%u %dsecs"
>> +			" (debug0=%#x, debug11=%#x)\n",

> Probably better with the format coalesced:

> 		CH_WARN(adap, "SGE idma%u, queue%u, maybe stuck state%u %dsecs (debug0=%#x, debug11=%#x)\n",

    Surely better, as otherwise it shouldn't pass scripts/checkpatch.pl.

WBR, Sergei

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
