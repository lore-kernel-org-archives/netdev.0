From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: Re: [PATCH net-next v2 02/10] net: dsa: lan9303: Do not
 disable/enable switch fabric port 0 at startup
Date: Thu, 27 Jul 2017 12:39:10 +0200
Message-ID: <226cd9be-0e4c-f88a-046d-3d3e0f3ce47a@egil-hjelmeland.no>
References: <20170725161553.30147-1-privat@egil-hjelmeland.no>
 <20170725161553.30147-3-privat@egil-hjelmeland.no>
 <20170726165853.GO12049@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: corbet@lwn.net, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, davem@davemloft.net, kernel@pengutronix.de,
        linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170726165853.GO12049@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 26. juli 2017 18:58, Andrew Lunn wrote:
> On Tue, Jul 25, 2017 at 06:15:45PM +0200, Egil Hjelmeland wrote:
>> For some mysterious reason enable switch fabric port 0 TX fails to
>> work, when the TX has previous been disabled. Resolved by not
>> disable/enable switch fabric port 0 at startup. Port 1 and 2 are
>> still disabled in early init.
>>
>> Signed-off-by: Egil Hjelmeland <privat@egil-hjelmeland.no>
>> ---
>>   drivers/net/dsa/lan9303-core.c | 7 -------
>>   1 file changed, 7 deletions(-)
>>
>> diff --git a/drivers/net/dsa/lan9303-core.c b/drivers/net/dsa/lan9303-core.c
>> index e622db586c3d..c2b53659f58f 100644
>> --- a/drivers/net/dsa/lan9303-core.c
>> +++ b/drivers/net/dsa/lan9303-core.c
>> @@ -557,9 +557,6 @@ static int lan9303_disable_processing(struct lan9303 *chip)
>>   {
>>   	int ret;
>>   
>> -	ret = lan9303_disable_packet_processing(chip, LAN9303_PORT_0_OFFSET);
>> -	if (ret)
>> -		return ret;
>>   	ret = lan9303_disable_packet_processing(chip, LAN9303_PORT_1_OFFSET);
>>   	if (ret)
>>   		return ret;
>> @@ -633,10 +630,6 @@ static int lan9303_setup(struct dsa_switch *ds)
>>   	if (ret)
>>   		dev_err(chip->dev, "failed to separate ports %d\n", ret);
>>   
>> -	ret = lan9303_enable_packet_processing(chip, LAN9303_PORT_0_OFFSET);
>> -	if (ret)
>> -		dev_err(chip->dev, "failed to re-enable switching %d\n", ret);
>> -
> 
> Does this mean you are relying on something else enabling port 0? The
> bootloader?
> 
> I'm wondering if it is better to keep the enable, but remove the
> disable?
> 
> 	Andrew
> 

The (switch engine) ports are enabled by default. The only thing our
bootloader does is to set gpo so the lan9303 is kept in reset until
the linux driver starts. When I test with the next-next kernel I just
specify the reset-gpo in DTS and the driver pulls it out of reset.

Keeping the enable does no harm, as far as I recall, but I can
double check that when I get time. I have no idea why the original
mainline code does not work for me. Maybe it is a timing issue?
