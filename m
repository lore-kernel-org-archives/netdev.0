From: Ivan Safonov <insafonov@gmail.com>
Subject: Re: [PATCH] /drivers/net/wireless/ath/ath9k remove unnecessary ?:
 operator
Date: Tue, 29 Dec 2015 01:38:02 +0700
Message-ID: <5681818A.9060406@gmail.com>
References: <20151228134852.GA10572@alpha.sfu-kras.ru>
 <1451325412.3219.12.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kalle Valo <kvalo@codeaurora.org>, linux-wireless@vger.kernel.org,
	ath9k-devel@lists.ath9k.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>,
	QCA ath9k Development <ath9k-devel@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1451325412.3219.12.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/29/2015 12:56 AM, Joe Perches wrote:
> On Mon, 2015-12-28 at 20:48 +0700, Ivan Safonov wrote:
>> ((thermometer < 0) ? 0 : (thermometer == X)) and (thermometer == X) are equal for X >= 0.
> X is not guaranteed to be >= 0 here

X is fixed constant. In this case X is {0, 1, 2}.

>> @@ -4097,16 +4097,16 @@ static void ar9003_hw_thermometer_apply(struct ath_hw *ah)
>>   		REG_RMW_FIELD(ah, AR_PHY_65NM_CH2_RXTX4,
>>   			      AR_PHY_65NM_CH0_RXTX4_THERM_ON_OVR, therm_on);
>>   
>> -	therm_on = (thermometer < 0) ? 0 : (thermometer == 0);
>> +	therm_on = thermometer == 0;
> This code is not equivalent.
>
> Check what happens when thermometer is -1.

therm_on = (thermometer < 0) ? 0 : (thermometer == 0) =>
therm_on = (true) ? 0 : (thermometer == 0) =>

therm_on is 0


therm_on = thermometer == 0 =>

therm_on = false


false is equal to 0


Value of the thermometer variable isanerror code, or athermometercode. 
The thermometercode is never equal to the error code (thermometercode >= 
0, error code <0).
