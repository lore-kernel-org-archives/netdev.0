From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: Re: [PATCH v3 net-next 5/5] net: dsa: lan9303: refactor
 lan9303_get_ethtool_stats
Date: Thu, 3 Aug 2017 22:26:16 +0200
Message-ID: <4e6cf276-bca0-0a53-5d1d-fb882f776dfb@egil-hjelmeland.no>
References: <20170803094507.3439-1-privat@egil-hjelmeland.no>
 <20170803094507.3439-6-privat@egil-hjelmeland.no>
 <d91c3159-57a3-dea3-462e-24a4156127b2@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Florian Fainelli <f.fainelli@gmail.com>, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel@pengutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <d91c3159-57a3-dea3-462e-24a4156127b2@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Den 03. aug. 2017 20:04, skrev Florian Fainelli:
> On 08/03/2017 02:45 AM, Egil Hjelmeland wrote:
>> In lan9303_get_ethtool_stats: Get rid of 0x400 constant magic
>> by using new lan9303_read_switch_reg() inside loop.
>> Reduced scope of two variables.
>>
>> Signed-off-by: Egil Hjelmeland <privat@egil-hjelmeland.no>
>> ---
>>   drivers/net/dsa/lan9303-core.c | 26 ++++++++++++++++----------
>>   1 file changed, 16 insertions(+), 10 deletions(-)
>>
>> diff --git a/drivers/net/dsa/lan9303-core.c b/drivers/net/dsa/lan9303-core.c
>> index 6f409755ba1a..5aaa46146c27 100644
>> --- a/drivers/net/dsa/lan9303-core.c
>> +++ b/drivers/net/dsa/lan9303-core.c
>> @@ -435,6 +435,13 @@ static int lan9303_write_switch_port(
>>   		chip, LAN9303_SWITCH_PORT_REG(port, regnum), val);
>>   }
>>   
>> +static int lan9303_read_switch_port(
>> +	struct lan9303 *chip, int port, u16 regnum, u32 *val)
>> +{
> 
> This indentation is really funny, why not just break it up that way:
> 
> static int lan9303_read_switch_port(struct lan9303 *chip, int port
> 				    u16 regnum, u32 *val)
> {
> }
> 
> This applies to patch 5 as well, other than that:
> 
> Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
> 

Because it is the form that passes scripts/checkpatch.pl which I find
easiest to type and maintain.

- No need to fine tune spaces.
- No need to change indentation if later renaming function to name of
   different length.

Do you have any references backing up your claim this is wrong?

Cheers
Egil
