From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: Re: [PATCH net-next v2 08/10] net: dsa: lan9303: Added ALR/fdb/mdb
 handling
Date: Thu, 27 Jul 2017 13:04:44 +0200
Message-ID: <8c7c8f00-9a6a-6f68-5459-58ef59ff6c78@egil-hjelmeland.no>
References: <20170725161553.30147-1-privat@egil-hjelmeland.no>
 <20170725161553.30147-9-privat@egil-hjelmeland.no>
 <20170726174154.GS12049@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: corbet@lwn.net, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, davem@davemloft.net, kernel@pengutronix.de,
        linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20170726174154.GS12049@lunn.ch>
Content-Language: en-US
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 26. juli 2017 19:41, Andrew Lunn wrote:
> Hi Egil
> 
>> +/* This function will wait a while until mask & reg == value */
>> +/* Otherwise, return timeout */
>> +static int lan9303_csr_reg_wait(struct lan9303 *chip, int regno,
>> +				int mask, char value)
>> +{
>> +	int i;
>> +
>> +	for (i = 0; i < 0x1000; i++) {
>> +		u32 reg;
>> +
>> +		lan9303_read_switch_reg(chip, regno, &reg);
>> +		if ((reg & mask) == value)
>> +			return 0;
>> +	}
>> +	return -ETIMEDOUT;
> 
> Busy looping is probably not a good idea. Can you add a usleep()?
> 

Yes

>> +}
>> +
>> +static int _lan9303_alr_make_entry_raw(struct lan9303 *chip, u32 dat0, u32 dat1)
> 
> What does the _ indicate. I could understand having it when you have
> lan9303_alr_make_entry_raw() call _lan9303_alr_make_entry_raw() after
> taking a lock, but i don't see anything like that here.
> 
Just my sloppy convention for something private, deep down. I can remove
the _.

>> +{
>> +	struct lan9303_alr_cache_entry *entr = lan9303_alr_cache_find_mac(
>> +		chip, mac);
> 
> A long line like this should be split into a declaration and an
> assignment.
> 

OK


> 
> I would probably make this a separate patch.
> 
>    Andrew
> 

Got it.
