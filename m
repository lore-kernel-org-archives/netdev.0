From: David Miller <davem@davemloft.net>
Subject: Re: potential null pointer dereference in
 drivers/isdn/hisax/isdnl2.c
Date: Tue, 15 Feb 2011 12:15:53 -0800 (PST)
Message-ID: <20110215.121553.112596232.davem@davemloft.net>
References: <20110213.165309.123985803.davem@davemloft.net>
	<1297800556_10580@mail4.comsite.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	tj@kernel.org, isdn@linux-pingi.de, jj@chaosbits.net
To: miltonm@bga.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1297800556_10580@mail4.comsite.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Milton Miller <miltonm@bga.com>
Date: Tue, 15 Feb 2011 14:09:16 -0600

> On Mon, 14 Feb 2011 00:53:09 -0000, Dave Miler wrote:
>> diff --git a/drivers/isdn/hisax/isdnl2.c b/drivers/isdn/hisax/isdnl2.c
>> index 0858791..98ac835 100644
>> --- a/drivers/isdn/hisax/isdnl2.c
>> +++ b/drivers/isdn/hisax/isdnl2.c
>> @@ -1243,14 +1243,21 @@ l2_st7_tout_203(struct FsmInst *fi, int event, void *arg)
>>  	st->l2.rc = 0;
>>  }
>>  
>> +static int l2_hdr_space_needed(struct Layer2 *l2)
>> +{
>> +	int len = test_bit(FLG_LAPD, &l2->flag) ? 2 : 1;
>> +
>> +	return len + (test_bit(FLG_LAPD, &l2->flag) ? 2 : 1);
>> +}
>> +
> 
> That struck me as an funny way to write 2 * len, so I finally looked
> at the code.  I think one of those should be FLG_MOD128, but then
> at that point why not use the existing l2headersize(l2, ui) with
> ui = 0?
> 
> I see this is in linux-next of Feb 15, 2011.

Good catch, thanks.  I'll fix this.
