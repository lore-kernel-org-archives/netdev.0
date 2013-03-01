From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net-next 2/4] ixgbe: Remove driver specific fdb handlers.
Date: Fri, 01 Mar 2013 09:35:15 -0500
Message-ID: <5130BCA3.3080709@redhat.com>
References: <1362093183-5938-1-git-send-email-vyasevic@redhat.com> <1362093183-5938-3-git-send-email-vyasevic@redhat.com> <51304296.8080106@intel.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Gregory Rose <gregory.v.rose@intel.com>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29520 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750779Ab3CAOfT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Mar 2013 09:35:19 -0500
In-Reply-To: <51304296.8080106@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/01/2013 12:54 AM, John Fastabend wrote:
> On 2/28/2013 3:13 PM, Vlad Yasevich wrote:
>> Remove driver specific fdb handlers since they are the same
>> as the default ones.
>>
>> CC: John Fastabend <john.r.fastabend@intel.com>
>> CC: CC: Gregory Rose <gregory.v.rose@intel.com>
>> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
>> ---
>>   drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   81
>> -------------------------
>>   1 files changed, 0 insertions(+), 81 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>> b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>> index 68478d6..212b74e 100644
>> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>> @@ -6998,84 +6998,6 @@ static int ixgbe_set_features(struct net_device
>> *netdev,
>>       return 0;
>>   }
>>
>> -static int ixgbe_ndo_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
>> -                 struct net_device *dev,
>> -                 const unsigned char *addr,
>> -                 u16 flags)
>> -{
>
> [...]
>
>> -    if (is_unicast_ether_addr(addr) || is_link_local_ether_addr(addr)) {
>> -        u32 rar_uc_entries = IXGBE_MAX_PF_MACVLANS;
>> -
>> -        if (netdev_uc_count(dev) < rar_uc_entries)
>> -            err = dev_uc_add_excl(dev, addr);
>> -        else
>> -            err = -ENOMEM;
>
> OK after talking with Greg I realized there is a problem with
> just removing the add routine.
>
> The problem with this is we lose the ability to indicate the
> hardware table is full and return ENOMEM. Although our set_rx_mode
> routine will put the device in promisc mode this won't forward
> packets from a VF to the PF in the SR-IOV case.
>
> So we either need to leave ixgbe_ndo_fdb_add() or let set_rx_mode
> return an -ENOMEM error. I believe in the first case we can still
> remove the dump and del cases.
>
> Sorry for the hassle took me a second review to catch it.

No problem.  That was the reason I left it in the first version (because
of different error handling).  I'll restore the add function.

-vlad
>
> .John
