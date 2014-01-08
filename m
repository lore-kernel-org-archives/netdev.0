From: Ding Tianhong <dingtianhong-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v3.5 17/19] mwifiex: slight optimization of addr compare
Date: Wed, 8 Jan 2014 10:58:09 +0800
Message-ID: <52CCBEC1.1010309@huawei.com>
References: <52BC15E7.7050205@huawei.com> <477F20668A386D41ADCC57781B1F70430F534B5541@SC-VEXCH1.marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Bing Zhao <bzhao-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <477F20668A386D41ADCC57781B1F70430F534B5541-r8ILAu4/owuHXkj8w7BxOhL4W9x8LtSr@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 2014/1/8 10:50, Bing Zhao wrote:
> Hi Ding,
> 
>> Use possibly more efficient ether_addr_equal
>> instead of memcmp.
> 
>> @@ -782,8 +782,7 @@ static int mwifiex_ret_ibss_coalescing_status(struct mwifiex_private *priv,
>>  	}
>>
>>  	/* If BSSID is diff, modify current BSS parameters */
>> -	if (memcmp(priv->curr_bss_params.bss_descriptor.mac_address,
>> -		   ibss_coal_resp->bssid, ETH_ALEN)) {
>> +	if (!ether_addr_equal(priv->curr_bss_params.bss_descriptor.mac_address, ibss_coal_resp->bssid))
> 
> Could you break the line?
> If you run "checkpatch.pl" you will spot this warning.
> 
>>  	if (!IS_11N_ENABLED(priv) ||
>> -	    memcmp(priv->curr_addr, rx_pkt_hdr->eth803_hdr.h_dest, ETH_ALEN)) {
>> +	    !ether_addr_equal_unaligned(priv->curr_addr, rx_pkt_hdr->eth803_hdr.h_dest)) {
> 
> Also over 80 characters here.
> 
> Thanks,
> Bing
> 

Ok, thanks

Regards
Ding

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
