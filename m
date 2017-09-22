From: Colin Ian King <colin.king@canonical.com>
Subject: Re: [PATCH] e1000: avoid null pointer dereference on invalid stat
 type
Date: Fri, 22 Sep 2017 12:55:16 +0100
Message-ID: <ea758981-9329-9594-5e25-f75376bc61a5@canonical.com>
References: <20170921220158.19341-1-colin.king@canonical.com>
 <20170922115038.ckvl6zsmadrqiige@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170922115038.ckvl6zsmadrqiige@mwanda>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 22/09/17 12:50, Dan Carpenter wrote:
> On Thu, Sep 21, 2017 at 11:01:58PM +0100, Colin King wrote:
>> @@ -1837,12 +1838,13 @@ static void e1000_get_ethtool_stats(struct net_device *netdev,
>>  			p = (char *)adapter + stat->stat_offset;
>>  			break;
>>  		default:
>> +			p = NULL;
>>  			WARN_ONCE(1, "Invalid E1000 stat type: %u index %d\n",
>>  				  stat->type, i);
>>  			break;
>>  		}
>>  
>> -		if (stat->sizeof_stat == sizeof(u64))
>> +		if (p && stat->sizeof_stat == sizeof(u64))
>>  			data[i] = *(u64 *)p;
>>  		else
>>  			data[i] = *(u32 *)p;
>                                    ^^^^^^^^
> 
> The else side will still crash.
> 
> regards,
> dan carpenter
> 
Thanks, stupid me. I'll fix that up.
