From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] net: dsa: mv88e6xxx: debug ATU Age Time
Date: Mon, 13 Mar 2017 15:42:36 -0700
Message-ID: <b7d0e92f-45cb-929d-a724-2a582621f8e1@gmail.com>
References: <20170313192043.12478-1-vivien.didelot@savoirfairelinux.com>
 <20170313223932.GC14183@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Jason Cobham <jcobham@questertangent.com>
To: Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170313223932.GC14183@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/13/2017 03:39 PM, Andrew Lunn wrote:
> On Mon, Mar 13, 2017 at 03:20:43PM -0400, Vivien Didelot wrote:
>> The ATU ageing time value programmed in the switch is rounded up to the
>> nearest multiple of its coefficient (variable depending on the model.)
>>
>> Add a debug message to inform the user about the exact programmed value.
>>
>> On 6352, "brctl setageing br0 18" gives "AgeTime set to 0x01 (15000 ms)"
>> while on 6390 we get "AgeTime set to 0x05 (18750 ms)".
>>
>> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
>> ---
>>  drivers/net/dsa/mv88e6xxx/global1_atu.c | 9 ++++++++-
>>  1 file changed, 8 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/dsa/mv88e6xxx/global1_atu.c b/drivers/net/dsa/mv88e6xxx/global1_atu.c
>> index f6cd3c939da4..bac34737b096 100644
>> --- a/drivers/net/dsa/mv88e6xxx/global1_atu.c
>> +++ b/drivers/net/dsa/mv88e6xxx/global1_atu.c
>> @@ -65,7 +65,14 @@ int mv88e6xxx_g1_atu_set_age_time(struct mv88e6xxx_chip *chip,
>>  	val &= ~0xff0;
>>  	val |= age_time << 4;
>>  
>> -	return mv88e6xxx_g1_write(chip, GLOBAL_ATU_CONTROL, val);
>> +	err = mv88e6xxx_g1_write(chip, GLOBAL_ATU_CONTROL, val);
>> +	if (err)
>> +		return err;
>> +
>> +	dev_dbg(chip->dev, "AgeTime set to 0x%02x (%d ms)\n", age_time,
>> +		age_time * coeff);
>> +
> 
> Hi Vivien
> 
> You could put the dev_dbg before the mv88e6xxx_g1_write(), to keep the
> code simpler. If this write fails, we expect a lot of other things to
> go horribly wrong, so having one debug message being not quite accurate
> is not important.

The debug message would not be printed in case mv88e6xxx_g1_write()
fails, also, having the message printed after the write occurred is a
good way to make sure the write did make it through. Did I miss
something in what you are suggesting here?
-- 
Florian
