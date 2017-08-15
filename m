From: Greg Edwards <gedwards@ddn.com>
Subject: Re: [net-next 11/12] igbvf: convert msleep to mdelay in atomic
 context
Date: Tue, 15 Aug 2017 13:32:11 -0600
Message-ID: <20170815193210.GC27768@psuche>
References: <20170809214746.28139-1-jeffrey.t.kirsher@intel.com>
 <20170809214746.28139-12-jeffrey.t.kirsher@intel.com>
 <063D6719AE5E284EB5DD2968C1650D6DD0054ACD@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "nhorman@redhat.com" <nhorman@redhat.com>,
        "sassmann@redhat.com" <sassmann@redhat.com>,
        "jogreene@redhat.com" <jogreene@redhat.com>
To: 'Jeff Kirsher' <jeffrey.t.kirsher@intel.com>,
        David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from legacy.ddn.com ([64.47.133.206]:51353 "EHLO legacy.ddn.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751119AbdHOThd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Aug 2017 15:37:33 -0400
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DD0054ACD@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 14, 2017 at 10:17:31AM +0000, David Laight wrote:
> From: Jeff Kirsher
>> Sent: 09 August 2017 22:48
>> From: Greg Edwards <gedwards@ddn.com>
>>
>> This fixes a "scheduling while atomic" splat seen with
>> CONFIG_DEBUG_ATOMIC_SLEEP enabled.
>>
>> Signed-off-by: Greg Edwards <gedwards@ddn.com>
>> Tested-by: Aaron Brown <aaron.f.brown@intel.com>
>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> ---
>>  drivers/net/ethernet/intel/igbvf/vf.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/ethernet/intel/igbvf/vf.c b/drivers/net/ethernet/intel/igbvf/vf.c
>> index 1d3aa9adcaa8..9577ccf4b26a 100644
>> --- a/drivers/net/ethernet/intel/igbvf/vf.c
>> +++ b/drivers/net/ethernet/intel/igbvf/vf.c
>> @@ -149,7 +149,7 @@ static s32 e1000_reset_hw_vf(struct e1000_hw *hw)
>>  		msgbuf[0] = E1000_VF_RESET;
>>  		mbx->ops.write_posted(hw, msgbuf, 1);
>>
>> -		msleep(10);
>> +		mdelay(10);
>
> Spinning for 10ms seems somewhat sub-optimal

Jeff,

Do we even need this delay?  The subsequent read_posted() will poll for
the PF's mailbox reply for up to 1s.

Greg
