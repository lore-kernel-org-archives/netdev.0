From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 8/9] ipvlan: improve compiler hints
Date: Thu, 27 Apr 2017 12:05:26 -0400 (EDT)
Message-ID: <20170427.120526.172017262253091302.davem@davemloft.net>
References: <20170427145142.15830-1-marco.chiappero@intel.com>
        <20170427145142.15830-9-marco.chiappero@intel.com>
        <B1C1DF2ACD01FD4881736AA51731BAB2B2EFB2@ORSMSX107.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: marco.chiappero@intel.com, netdev@vger.kernel.org,
        jeffrey.t.kirsher@intel.com, sainath.grandhi@intel.com,
        maheshb@google.com
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42496 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754110AbdD0QF2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 12:05:28 -0400
In-Reply-To: <B1C1DF2ACD01FD4881736AA51731BAB2B2EFB2@ORSMSX107.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Date: Thu, 27 Apr 2017 15:21:16 +0000

>> -----Original Message-----
>> From: Chiappero, Marco
>> Sent: Thursday, April 27, 2017 7:52 AM
>> To: netdev@vger.kernel.org
>> Cc: David S . Miller <davem@davemloft.net>; Kirsher, Jeffrey T
>> <jeffrey.t.kirsher@intel.com>; Duyck, Alexander H
>> <alexander.h.duyck@intel.com>; Grandhi, Sainath
>> <sainath.grandhi@intel.com>; Mahesh Bandewar <maheshb@google.com>;
>> Chiappero, Marco <marco.chiappero@intel.com>
>> Subject: [PATCH net-next 8/9] ipvlan: improve compiler hints
>> 
>> Extend inlining and branch prediction hints.
>> 
>> Signed-off-by: Marco Chiappero <marco.chiappero@intel.com>
>> ---
>>  drivers/net/ipvlan/ipvlan_core.c | 6 +++---
>>  1 file changed, 3 insertions(+), 3 deletions(-)
>> 
>> diff --git a/drivers/net/ipvlan/ipvlan_core.c b/drivers/net/ipvlan/ipvlan_core.c
>> index a9fc1b5..67e342d 100644
>> --- a/drivers/net/ipvlan/ipvlan_core.c
>> +++ b/drivers/net/ipvlan/ipvlan_core.c
>> @@ -88,7 +88,7 @@ void ipvlan_ht_addr_del(struct ipvl_addr *addr)
>>  	hlist_del_init_rcu(&addr->hlnode);
>>  }
>> 
>> -unsigned int ipvlan_mac_hash(const unsigned char *addr)
>> +inline unsigned int ipvlan_mac_hash(const unsigned char *addr)
>>  {
>>  	u32 hash = jhash_1word(__get_unaligned_cpu32(addr + 2),
>>  			       ipvlan_jhash_secret);
> 
> I'm kind of surprised this isn't causing a problem with differing
> declarations between the declaration here and the declaration in
> ipvlan.h. Normally for inlining something like this you would change
> it to a "static inline" and move the entire declaration into the
> header file.

No inlines in foo.c files please, seriously let the compiler decide
it knows better than you.
