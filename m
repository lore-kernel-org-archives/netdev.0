From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: Re: [PATCH net-next 2/2] net: dsa: lan9303: Simplify
 lan9303_xxx_packet_processing() usage
Date: Mon, 31 Jul 2017 16:58:40 +0200
Message-ID: <3eafb133-2b39-a1c5-6c01-917799fb6320@egil-hjelmeland.no>
References: <20170731113355.4284-1-privat@egil-hjelmeland.no>
 <20170731113355.4284-3-privat@egil-hjelmeland.no>
 <87379c4sfe.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <3207fcff-8318-9b17-c546-026ab1a1511b@egil-hjelmeland.no>
 <87o9s01xb3.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        andrew@lunn.ch, f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel@pengutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87o9s01xb3.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 31. juli 2017 16:43, Vivien Didelot wrote:
> Hi Egil,
> 
> Egil Hjelmeland <privat@egil-hjelmeland.no> writes:
> 
>>>> +	for (p = 0; p <= 2; p++) {
>>>
>>> Exclusive limits are often prefer, i.e. 'p < 3'.
>>>
>> OK, that can be nice when I later introduce LAN9303_NUM_PORTS = 3.
> 
> This is indeed another reason what exclusive limits are prefered ;-)
> 
>>>> +		int ret;
>>>> +
>>>> +		ret = lan9303_disable_packet_processing(chip, p);
>>>> +		if (ret)
>>>> +			return ret;
>>>
>>> When any non-zero return code means an error, we usually see 'err'
>>> instead of 'ret'.
>>>
>>
>> But 'ret' is used throughout the rest of the file. Is it not better to
>> be locally consistent?
> 
> You are correct, I was missing a bit of context here.
> 
>>>>    	case 1:
>>>> -		return lan9303_enable_packet_processing(chip, port);
>>>
>>> Is this deletion intentional? The commit message does not explain this.
>>>
>>> When possible, it is appreciated to separate functional from
>>> non-functional changes. For example one commit adding the loop in
>>> lan9303_disable_processing and another one to not enable/disable packet
>>> processing on port 1.
>>>
>>
>> Case fall through, the change is purely non-functional.
>>
>> You are perhaps thinking of the patch in my first series where I removed
>> disable of port 0. I have put that on hold. Juergen says that the
>> mainline driver works out of the box for him. So I will investigate
>> that problem bit more.
> 
> Correct! I misread, my bad. This is indeed cleaner with this patch. With
> the LAN9303_NUM_PORTS limit and detailed commit message, the patch LGTM.
> 
> 
> Thanks,
> 
>          Vivien
> 

Would doing

-	chip->ds = dsa_switch_alloc(chip->dev, DSA_MAX_PORTS);
+	chip->ds = dsa_switch_alloc(chip->dev, LAN9303_NUM_PORTS);

at the same time be good, or breaking the scope of the patch?

Egil
