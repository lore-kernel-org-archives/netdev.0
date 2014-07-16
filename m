From: Sonic Zhang <sonic.adi@gmail.com>
Subject: Re: [PATCH v4] bfin_mac: convert bfin Ethernet driver to NAPI framework
Date: Wed, 16 Jul 2014 17:46:13 +0800
Message-ID: <CAJxxZ0MxpY7ZpgR39zDexURieAr7vNqfGCZpfgwcnwMRuzoD0w@mail.gmail.com>
References: <1405413820-28739-1-git-send-email-sonic.adi@gmail.com>
	<53C4EC35.1080205@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	adi-buildroot-devel@lists.sourceforge.net,
	Sonic Zhang <sonic.zhang@analog.com>
To: Varka Bhadram <varkabhadram@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f51.google.com ([209.85.219.51]:39727 "EHLO
	mail-oa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751361AbaGPJqO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2014 05:46:14 -0400
Received: by mail-oa0-f51.google.com with SMTP id o6so682286oag.24
        for <netdev@vger.kernel.org>; Wed, 16 Jul 2014 02:46:13 -0700 (PDT)
In-Reply-To: <53C4EC35.1080205@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Varka,

On Tue, Jul 15, 2014 at 4:54 PM, Varka Bhadram <varkabhadram@gmail.com> wrote:
> On 07/15/2014 02:13 PM, Sonic Zhang wrote:
>>
>> From: Sonic Zhang <sonic.zhang@analog.com>
>>
>> Ethernet RX DMA buffers are polled in NAPI work queue other than received
>> directly in DMA RX interrupt handler.
>>
>> Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>
>>
>> ---
>> v2-changes:
>> - avoid test NAPI_STATE_NPSVC bit in net device driver
>>
>> v3-changes:
>> - use tabs while indenting the code
>>
>> v4-changes:
>> - unconditionally compete the NAPI poll and re-enable the MAC_RX IRQ
>>
>> Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>
>> ---
>>   drivers/net/ethernet/adi/bfin_mac.c | 79
>> +++++++++++++++++++++++--------------
>>   drivers/net/ethernet/adi/bfin_mac.h |  1 +
>>   2 files changed, 50 insertions(+), 30 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/adi/bfin_mac.c
>> b/drivers/net/ethernet/adi/bfin_mac.c
>> index 7ae74d4..b838e81 100644
>> --- a/drivers/net/ethernet/adi/bfin_mac.c
>> +++ b/drivers/net/ethernet/adi/bfin_mac.c
>> @@ -1218,11 +1218,13 @@ out:
>>   #define RX_ERROR_MASK (RX_LONG | RX_ALIGN | RX_CRC | RX_LEN | \
>>         RX_FRAG | RX_ADDR | RX_DMAO | RX_PHY | RX_LATE | RX_RANGE)
>>   -static void bfin_mac_rx(struct net_device *dev)
>> +static void bfin_mac_rx(struct napi_struct *napi, int budget)
>>   {
>> +       struct bfin_mac_local *lp = container_of(napi,
>> +                               struct bfin_mac_local, napi);
>
>
> should match open parenthesis
>
>
> struct bfin_mac_local *lp = container_of(napi,
>                                          struct bfin_mac_local,
>                                          napi);
>

OK.

Thanks,

Sonic
