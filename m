From: Vlad Zolotarov <vladz@cloudius-systems.com>
Subject: Re: [RFC PATCH net-next 3/5] ixgbe: Add GET_RSS_KEY command to VF-PF
 channel commands set
Date: Tue, 30 Dec 2014 21:29:11 +0200
Message-ID: <54A2FD07.3090408@cloudius-systems.com>
References: <1419957035-1078-1-git-send-email-vladz@cloudius-systems.com>	<1419957035-1078-4-git-send-email-vladz@cloudius-systems.com> <CAL3LdT50tUsJOW+y15GbO=90UDYWNLjMyOF6AqFgj_ciqBeTUQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Gleb Natapov <gleb@cloudius-systems.com>,
	Avi Kivity <avi@cloudius-systems.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:53527 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751829AbaL3T3P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Dec 2014 14:29:15 -0500
Received: by mail-wg0-f49.google.com with SMTP id n12so21006022wgh.22
        for <netdev@vger.kernel.org>; Tue, 30 Dec 2014 11:29:14 -0800 (PST)
In-Reply-To: <CAL3LdT50tUsJOW+y15GbO=90UDYWNLjMyOF6AqFgj_ciqBeTUQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 12/30/14 21:23, Jeff Kirsher wrote:
> On Tue, Dec 30, 2014 at 8:30 AM, Vlad Zolotarov
> <vladz@cloudius-systems.com> wrote:
>> 82599 VFs and PF share the same RSS Key. Therefore we will return
>> the same RSS key for all VFs.
>>
>> Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
>> ---
>>   drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h   |  2 ++
>>   drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 25 +++++++++++++++++++++++++
>>   2 files changed, 27 insertions(+)
>>
>> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h
>> index c1123d9..52e775b 100644
>> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h
>> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h
>> @@ -97,6 +97,8 @@ enum ixgbe_pfvf_api_rev {
>>   #define IXGBE_VF_GET_RETA_1    0x0b /* get RETA[12..23] */
>>   #define IXGBE_VF_GET_RETA_2    0x0c /* get RETA[24..31] */
>>
>> +#define IXGBE_VF_GET_RSS_KEY   0x0d /* get RSS key */
>> +
>>   /* GET_QUEUES return data indices within the mailbox */
>>   #define IXGBE_VF_TX_QUEUES     1       /* number of Tx queues supported */
>>   #define IXGBE_VF_RX_QUEUES     2       /* number of Rx queues supported */
>> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
>> index 84db1a5..fc8233e 100644
>> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
>> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
>> @@ -970,6 +970,28 @@ static int ixgbe_get_vf_reta(struct ixgbe_adapter *adapter,
>>          return 0;
>>   }
>>
>> +static int ixgbe_get_vf_rss_key(struct ixgbe_adapter *adapter,
>> +                               u32 *msgbuf, u32 vf)
>> +{
>> +       struct ixgbe_hw *hw = &adapter->hw;
>> +       int i;
>> +       u32 *rss_key = &msgbuf[1];
>> +
>> +       /* verify the PF is supporting the correct API */
>> +       switch (adapter->vfinfo[vf].vf_api) {
>> +       case ixgbe_mbox_api_12:
>> +               break;
>> +       default:
>> +               return -EPERM;
>> +       }
> Same as in patch 01 of the series, a switch statement is overkill for
> a single case.  It would be far simpler to just have
>
> if (adapter->vfinfo[vf].vf_api != ixgbe_mbox_api_12)
>          return -EPERM;
>
> Later on, if there are multiple API's or future API's that also
> support this, then we could move to a case statement.

Got it. Will fix.
Thanks.
