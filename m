From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next 3/6] net: bridge: break if __br_mdb_del fails
Date: Thu, 18 May 2017 18:25:11 +0300
Message-ID: <1211f3cb-c5f5-a9bd-638b-bfcb99fd1bed@cumulusnetworks.com>
References: <20170517212709.6473-1-vivien.didelot@savoirfairelinux.com>
 <20170517212709.6473-4-vivien.didelot@savoirfairelinux.com>
 <5d8f53ea-a9de-7c76-f088-48c5357cb2a2@cumulusnetworks.com>
 <877f1edwxp.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Stephen Hemminger <stephen@networkplumber.org>,
        "moderated list:ETHERNET BRIDGE" <bridge@lists.linux-foundation.org>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:35357 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934161AbdERPZO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 11:25:14 -0400
Received: by mail-wm0-f54.google.com with SMTP id b84so205864121wmh.0
        for <netdev@vger.kernel.org>; Thu, 18 May 2017 08:25:13 -0700 (PDT)
In-Reply-To: <877f1edwxp.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/18/17 6:08 PM, Vivien Didelot wrote:
> Hi Nikolay,
> 
> Nikolay Aleksandrov <nikolay@cumulusnetworks.com> writes:
> 
>>>    			err = __br_mdb_del(br, entry);
>>> -			if (!err)
>>> -				__br_mdb_notify(dev, p, entry, RTM_DELMDB);
>>> +			if (err)
>>> +				break;
>>> +			__br_mdb_notify(dev, p, entry, RTM_DELMDB);
>>>    		}
>>>    	} else {
>>>    		err = __br_mdb_del(br, entry);
>>>
>>
>> This can potentially break user-space scripts that rely on the best-effort
>> behaviour, this is the normal "delete without vid & enabled vlan filtering".
>> You can check the fdb delete code which does the same, this was intentional.
>>
>> You can add an mdb entry without a vid to all vlans, add a vlan and then try
>> to remove it from all vlans where it is present - with this patch obviously
>> that will fail at the new vlan.
> 
> OK good to know. That intention wasn't obvious. I can make __br_mdb_del
> return void instead? What about the rest of the patchset if I do so?
> 
> Thanks,
> 
>          Vivien
> 

If you make it return void we will not be able to return proper error value
when doing a single operation (the else case). About the rest I see only some
minor style issues, I'll comment on the respective patches. Another minor nit is 
using switch() instead of if/else for the message types but that is really up to 
you, I don't mind either way. :-)

Cheers,
  Nik
