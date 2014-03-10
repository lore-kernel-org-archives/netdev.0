From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next 1/2] vlan: add proto for proc interface
Date: Mon, 10 Mar 2014 09:33:32 +0800
Message-ID: <531D166C.5070905@huawei.com>
References: <1394194251-11656-1-git-send-email-dingtianhong@huawei.com> <1394194251-11656-2-git-send-email-dingtianhong@huawei.com> <20140307121522.GA11396@macbook.localnet>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:11887 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751987AbaCJBd4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Mar 2014 21:33:56 -0400
In-Reply-To: <20140307121522.GA11396@macbook.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/3/7 20:15, Patrick McHardy wrote:
> On Fri, Mar 07, 2014 at 08:10:50PM +0800, Ding Tianhong wrote:
>> The vlan could support 2 proto: 802.1q and 802.1ad, so add it to
>> proc interface, the user could easily distinguish the proto for
>> each vlan dev.
>>
>> And the dev->priv_flags seems inappropriate, modify to Priv_Flags,
>> looks more comfortable.
> 
> The proc interface is obsolete, but this doesn't mean you're allowed
> to break it. This information is available through netlink. The proc
> interface should not be touched.
> 
> Nacked-by: Patrick McHardy <kaber@trash.net>
> 

Ok, agree.

>>
>> ---------------------- the old format: --------------------------
>>
>> eth2.10  VID: 10         REORDER_HDR: 1  dev->priv_flags: 1
>>          total frames received            5
>>           total bytes received          336
>>       Broadcast/Multicast Rcvd            0
>>
>>       total frames transmitted           13
>>        total bytes transmitted         1026
>> Device: eth2
>> INGRESS priority mappings: 0:0  1:0  2:0  3:0  4:0  5:0  6:0 7:0
>>  EGRESS priority mappings:
>>
>> ----------------------- the new format: -------------------------
>>
>> eth2.20  Proto: 802.1q  VID: 20  REORDER_HDR: 1  Priv_Flags: 1
>>          total frames received            0
>>           total bytes received            0
>>       Broadcast/Multicast Rcvd            0
>>
>>       total frames transmitted            0
>>        total bytes transmitted            0
>> Device: eth2
>> INGRESS priority mappings: 0:0  1:0  2:0  3:0  4:0  5:0  6:0 7:0
>>  EGRESS priority mappings:
>>
>> ----------------------------------------------------------------
>>
>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>> ---
>>  net/8021q/vlanproc.c | 6 ++++--
>>  1 file changed, 4 insertions(+), 2 deletions(-)
>>
>> diff --git a/net/8021q/vlanproc.c b/net/8021q/vlanproc.c
>> index 1d0e8921..a40abbc 100644
>> --- a/net/8021q/vlanproc.c
>> +++ b/net/8021q/vlanproc.c
>> @@ -285,8 +285,10 @@ static int vlandev_seq_show(struct seq_file *seq, void *offset)
>>  
>>  	stats = dev_get_stats(vlandev, &temp);
>>  	seq_printf(seq,
>> -		   "%s  VID: %d	 REORDER_HDR: %i  dev->priv_flags: %hx\n",
>> -		   vlandev->name, vlan->vlan_id,
>> +		   "%s  Proto: %s  VID: %d  REORDER_HDR: %i  Priv_Flags: %hx\n",
>> +		   vlandev->name,
>> +		   vlan->vlan_proto == htons(ETH_P_8021Q) ? "802.1q" : "802.1ad",
>> +		   vlan->vlan_id,
>>  		   (int)(vlan->flags & 1), vlandev->priv_flags);
>>  
>>  	seq_printf(seq, fmt64, "total frames received", stats->rx_packets);
>> -- 
>> 1.8.0
>>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> .
> 
