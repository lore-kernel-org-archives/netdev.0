From: Colin Ian King <colin.king@canonical.com>
Subject: Re: [PATCH][net-next] net: bridge: remove redundant check to see if
 err is set
Date: Tue, 7 Feb 2017 11:43:50 +0000
Message-ID: <32024608-8430-9d89-eec2-98057d4e2eb4@canonical.com>
References: <20170207105638.17918-1-colin.king@canonical.com>
 <d92d3afc-140f-8959-c6ea-9758eb1aa539@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        "David S . Miller" <davem@davemloft.net>,
        bridge@lists.linux-foundation.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:46465 "EHLO
        youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753285AbdBGLpY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 06:45:24 -0500
In-Reply-To: <d92d3afc-140f-8959-c6ea-9758eb1aa539@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

..and one more thing, in net/bridge/br_netlink_tunnel.c,
__get_num_vlan_tunnel_infos, are the args to vlan_tunnel_id_isrange()
the wrong way around? I'm not 100% sure, but I'd thought I'd flag it up.


        if (v_start) {
                if ((v_end->vid - v->vid) > 0 &&
                    vlan_tunnel_id_isrange(v_end, v) > 0)
                        num_tinfos += 2;
                else
                        num_tinfos += 1;
        }



On 07/02/17 11:30, Nikolay Aleksandrov wrote:
> On 07/02/17 11:56, Colin King wrote:
>> From: Colin Ian King <colin.king@canonical.com>
>>
>> The error check on err is redundant as it is being checked
>> previously each time it has been updated.  Remove this redundant
>> check.
>>
>> Detected with CoverityScan, CID#140030("Logically dead code")
>>
>> Signed-off-by: Colin Ian King <colin.king@canonical.com>
>> ---
>>  net/bridge/br_netlink.c | 3 ---
>>  1 file changed, 3 deletions(-)
>>
>> diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
>> index fc5d885..cdc4e2a 100644
>> --- a/net/bridge/br_netlink.c
>> +++ b/net/bridge/br_netlink.c
>> @@ -612,9 +612,6 @@ static int br_afspec(struct net_bridge *br,
>>  				return err;
>>  			break;
>>  		}
>> -
>> -		if (err)
>> -			return err;
>>  	}
>>  
>>  	return err;
>>
> 
> Actually that code can be reduced further, I'll follow up with a patch later.
> 
> Reviewed-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> --
> To unsubscribe from this list: send the line "unsubscribe kernel-janitors" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
