From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [2.6.11-rc4-mm1 patch] fix buggy IEEE80211_CRYPT_* selects
Date: Wed, 02 Mar 2005 17:41:50 -0500
Message-ID: <4226412E.6070403@pobox.com>
References: <20050223014233.6710fd73.akpm@osdl.org>	<20050226113123.GJ3311@stusta.de>	<42256078.1040002@pobox.com>	<20050302140833.GD4608@stusta.de>	<42261004.4000501@pobox.com>	<20050302123829.51dbc44b.akpm@osdl.org>	<42262B08.2040401@pobox.com> <20050302131817.2e61805f.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bunk@stusta.de, netdev@oss.sgi.com, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20050302131817.2e61805f.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> Jeff Garzik <jgarzik@pobox.com> wrote:
> 
>>>Thing is, CRYPTO_AES on only selectable on x86.
>>
>> You're thinking about CRYPTO_AES_586.  But looking at crypto/Kconfig, 
>> the dependencies are a bit weird:
>>
>> config CRYPTO_AES
>>          tristate "AES cipher algorithms"
>>          depends on CRYPTO && !(X86 && !X86_64)
>> config CRYPTO_AES_586
>>          tristate "AES cipher algorithms (i586)"
>>          depends on CRYPTO && (X86 && !X86_64)
> 
> 
> That's pretty broken, isn't it?
> 
> Would be better to just do:
> 
> config CRYPTO_AES
> 	select CRYPTO_AES_586 if (X86 && !X86_64)
> 	select CRYPTO_AES_OTHER if !(X86 && !X86_64)
> 
> and hide CRYPTO_AES_586 and CRYPTO_AES_OTHER from the outside world.

Not really that easy.  For x86 we have

	aes
	aes-586
	aes-via

And my own personal custom-kernel preference is to use the C version of 
the code on my x86 and x86-64 boxes.

	Jeff
