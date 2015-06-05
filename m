From: Jaeden Amero <jaeden.amero@ni.com>
Subject: Re: [PATCH v2 3/3] net/phy: micrel: Center FLP timing at 16ms
Date: Fri, 05 Jun 2015 17:36:14 -0500
Message-ID: <5572245E.4080000@ni.com>
References: <1433534130-16323-1-git-send-email-jaeden.amero@ni.com> <1433534130-16323-4-git-send-email-jaeden.amero@ni.com> <55721027.6030509@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55721027.6030509@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/05/2015 04:09 PM, Sergei Shtylyov wrote:
>> @@ -441,6 +461,7 @@ static int ksz9031_config_init(struct phy_device
>> *phydev)
>>           "txd2-skew-ps", "txd3-skew-ps"
>>       };
>>       static const char *control_skews[2] = {"txen-skew-ps",
>> "rxdv-skew-ps"};
>> +    int result;
> 
>    You hardly need this variable...
> 
>>
>>       if (!of_node && dev->parent->of_node)
>>           of_node = dev->parent->of_node;
>> @@ -462,7 +483,10 @@ static int ksz9031_config_init(struct phy_device
>> *phydev)
>>                   MII_KSZ9031RN_TX_DATA_PAD_SKEW, 4,
>>                   tx_data_skews, 4);
>>       }
>> -    return 0;
>> +
>> +    result = ksz9031_center_flp_timing(phydev);
>> +
>> +    return result;
> 
>    Why not just return directly?
> 

Genius.

Thanks for the feedback. I'll post a v3.
