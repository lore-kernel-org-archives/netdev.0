From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: Re: [PATCH v3 net-next 3/5] net: dsa: lan9303: Simplify
 lan9303_xxx_packet_processing() usage
Date: Thu, 3 Aug 2017 22:16:42 +0200
Message-ID: <00f388c1-f0ab-6780-9644-4bf66868682e@egil-hjelmeland.no>
References: <20170803094507.3439-1-privat@egil-hjelmeland.no>
 <20170803094507.3439-4-privat@egil-hjelmeland.no>
 <5a67a44b-6887-1466-c0f3-ce65759d51db@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Florian Fainelli <f.fainelli@gmail.com>, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel@pengutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5a67a44b-6887-1466-c0f3-ce65759d51db@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Den 03. aug. 2017 20:06, skrev Florian Fainelli:
> On 08/03/2017 02:45 AM, Egil Hjelmeland wrote:
>> Simplify usage of lan9303_enable_packet_processing,
>> lan9303_disable_packet_processing()
>>
>> Signed-off-by: Egil Hjelmeland <privat@egil-hjelmeland.no>
> 
> Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
> 
> took a little while to figure out that we are utilizing fall through of
> the switch/case statement and that's why it's okay.
> 
>>
>>   static int lan9303_check_device(struct lan9303 *chip)
>> @@ -765,7 +766,6 @@ static int lan9303_port_enable(struct dsa_switch *ds, int port,
>>   	/* enable internal packet processing */
>>   	switch (port) {
>>   	case 1:
>> -		return lan9303_enable_packet_processing(chip, port);
>>   	case 2:
>>   		return lan9303_enable_packet_processing(chip, port);
>>   	default:

I suppose if we later change to dsa_switch_alloc(...,3), then it could
be further simplified to

if (port != 0)
	return lan9303_enable_packet_processing(chip, port);

Or perhaps no test is needed at all. The driver assumes port 0 is cpu
port, which is the sensible way to use the chip. (Because port 0 has
no phy, the others have phy). Declaring a different port as cpu port in
DTS will not work, but it will not crash the kernel.

Egil
