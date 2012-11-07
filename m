From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] cxgb4: Initialize data structures before using.
Date: Wed, 07 Nov 2012 14:31:27 -0500 (EST)
Message-ID: <20121107.143127.2060314019851524050.davem@davemloft.net>
References: <1352209029-4291-1-git-send-email-vipul@chelsio.com>
	<CANX6Dak5pFutKVn7hV_8-tYx4h67-gS2ud=CrArN--9e=ica5Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vipul@chelsio.com, netdev@vger.kernel.org, divy@chelsio.com,
	dm@chelsio.com, jay@chelsio.com
To: viral.vkm@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40559 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751356Ab2KGTbb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2012 14:31:31 -0500
In-Reply-To: <CANX6Dak5pFutKVn7hV_8-tYx4h67-gS2ud=CrArN--9e=ica5Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Viral Mehta <viral.vkm@gmail.com>
Date: Wed, 7 Nov 2012 16:42:09 +0530

> Hi,
> 
> On Tue, Nov 6, 2012 at 7:07 PM, Vipul Pandya <vipul@chelsio.com> wrote:
>>
>> We should not assume reserve fields to be don't cares as fields may change.
>> Clearing data structures before using.
>>
>> Signed-off-by: Jay Hernandez <jay@chelsio.com>
>> Signed-off-by: Vipul Pandya <vipul@chelsio.com>
>> ---
>>  drivers/net/ethernet/chelsio/cxgb4/t4_hw.c |    4 ++++
>>  1 files changed, 4 insertions(+), 0 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
>> index 32eec15..01fa5b7 100644
>> --- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
>> +++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
>> @@ -2519,6 +2519,7 @@ int t4_fw_bye(struct adapter *adap, unsigned int mbox)
>>  {
>>         struct fw_bye_cmd c;
>>
>> +       memset(&c, 0, sizeof(c));
> 
> struct fw_byte_cmd c = {0};
> 
> Isn't it better ?

There is no fundamental difference, as far as the compiler and
optimizations are concerned, it's pretty much identical.
