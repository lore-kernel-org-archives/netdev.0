From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [Bridge] [PATCH net-next v4 2/2] bridge: vlan: signal if anything
 changed on vlan add
Date: Thu, 26 Oct 2017 14:08:02 +0300
Message-ID: <0f1e8fb5-b9a8-b363-c080-65c23f76b25e@cumulusnetworks.com>
References: <f6c0da96-77f0-db19-7a9a-13b246d83d39@cumulusnetworks.com>
 <1508971954-3567-1-git-send-email-nikolay@cumulusnetworks.com>
 <1508971954-3567-3-git-send-email-nikolay@cumulusnetworks.com>
 <622bf4ff-e493-58f0-bedf-8183a82e8772@lab.ntt.co.jp>
 <3ad411f5-72fe-db6c-aa13-385dd1c10f36@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, bridge@lists.linux-foundation.org,
        mrv@mojatatu.com, dsa@cumulusnetworks.com, davem@davemloft.net
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:48130 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932286AbdJZLIH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 07:08:07 -0400
Received: by mail-lf0-f66.google.com with SMTP id a69so3283677lfe.5
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 04:08:06 -0700 (PDT)
In-Reply-To: <3ad411f5-72fe-db6c-aa13-385dd1c10f36@cumulusnetworks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26/10/17 14:02, Nikolay Aleksandrov wrote:
> On 26/10/17 13:16, Toshiaki Makita wrote:
>> On 2017/10/26 7:52, Nikolay Aleksandrov wrote:
>> ...
>>> @@ -559,6 +574,7 @@ int br_vlan_add(struct net_bridge *br, u16 vid, u16 flags)
>>>  
>>>  	ASSERT_RTNL();
>>>  
>>> +	*changed = false;
>>>  	vg = br_vlan_group(br);
>>>  	vlan = br_vlan_find(vg, vid);
>>>  	if (vlan) {
>>> @@ -576,9 +592,12 @@ int br_vlan_add(struct net_bridge *br, u16 vid, u16 flags)
>>>  			refcount_inc(&vlan->refcnt);
>>>  			vlan->flags |= BRIDGE_VLAN_INFO_BRENTRY;
>>>  			vg->num_vlans++;
>>> +			*changed = true;
>>>  		}
>>> -		__vlan_add_flags(vlan, flags);
>>> -		return 0;
>>> +		if (__vlan_add_flags(vlan, flags))
>>> +			*changed = true;
>>> +
>>> +		return ret;
>>
>> "ret" isn't always initialized here, is it?
>>
>>
>> Toshiaki Makita
> 
> Oh, good catch! Right you are, weird that there was no warning even with W=1 as
> I always check that before sending a set.
> 
> Thanks,
>  Nik
> 

Unfortunately that was a leftover from v0 of this set where I always initialized ret.
Will fix and send v5, thanks again.
