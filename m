From: Anirban Chakraborty <abchak@juniper.net>
Subject: Re: [PATCH net-next] xen-netfront: convert to GRO API
Date: Tue, 1 Oct 2013 20:32:56 +0000
Message-ID: <AC497311-B61D-4385-948B-2EDE3EAC37B5@juniper.net>
References: <1380545194-13419-1-git-send-email-wei.liu2@citrix.com>
 <1380547472.1302.45.camel@kazak.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Wei Liu <wei.liu2@citrix.com>,
	"<netdev@vger.kernel.org>" <netdev@vger.kernel.org>,
	"<xen-devel@lists.xen.org>" <xen-devel@lists.xen.org>,
	"<konrad.wilk@oracle.com>" <konrad.wilk@oracle.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co1ehsobe004.messaging.microsoft.com ([216.32.180.187]:46516
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753095Ab3JAUdH convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Oct 2013 16:33:07 -0400
In-Reply-To: <1380547472.1302.45.camel@kazak.uk.xensource.com>
Content-Language: en-US
Content-ID: <4604B52F3175EC4F9D96896A88A46C84@namprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Sep 30, 2013, at 6:24 AM, Ian Campbell <Ian.Campbell@citrix.com> wrote:

> On Mon, 2013-09-30 at 13:46 +0100, Wei Liu wrote:
>> Anirban was seeing netfront received MTU size packets, which downgraded
>> throughput. The following patch makes netfront use GRO API which
>> improves throughput for that case.
>> 
>> Signed-off-by: Wei Liu <wei.liu2@citrix.com>
>> Cc: Anirban Chakraborty <abchak@juniper.net>
> 
> Acked-by: Ian Campbell <ian.campbell@citrix.com>
> 
>> Acked-by: Konrad Wilk <konrad.wilk@oracle.com>
>> ---
>> drivers/net/xen-netfront.c |    4 +++-
>> 1 file changed, 3 insertions(+), 1 deletion(-)
>> 
>> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
>> index 36808bf..dd1011e 100644
>> --- a/drivers/net/xen-netfront.c
>> +++ b/drivers/net/xen-netfront.c
>> @@ -952,7 +952,7 @@ static int handle_incoming_queue(struct net_device *dev,
>> 		u64_stats_update_end(&stats->syncp);
>> 
>> 		/* Pass it up. */
>> -		netif_receive_skb(skb);
>> +		napi_gro_receive(&np->napi, skb);
>> 	}
>> 
>> 	return packets_dropped;
>> @@ -1051,6 +1051,8 @@ err:
>> 	if (work_done < budget) {
>> 		int more_to_do = 0;
>> 
>> +		napi_gro_flush(napi, false);
>> +
>> 		local_irq_save(flags);
>> 
>> 		RING_FINAL_CHECK_FOR_RESPONSES(&np->rx, more_to_do);
> 

We should apply it to stable as well. Thanks.
Anirban
