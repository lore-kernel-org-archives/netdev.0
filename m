From: John Stultz <john.stultz@linaro.org>
Subject: Re: [RFC][PATCH] wireless: ath9k: Convert from timespecs to ktime_t
Date: Wed, 30 Jul 2014 17:39:08 -0700
Message-ID: <53D9902C.1060002@linaro.org>
References: <1406764865-26860-1-git-send-email-john.stultz@linaro.org> <20140731102750.4a4c1315@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Peter Zijlstra <peterz@infradead.org>,
	David Miller <davem@davemloft.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	Felix Fietkau <nbd@openwrt.org>,
	Rajkumar Manoharan <rmanohar@qti.qualcomm.com>,
	netdev@vger.kernel.org,
	QCA ath9k Development <ath9k-devel@qca.qualcomm.com>,
	linux-next@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20140731102750.4a4c1315@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/30/2014 05:27 PM, Stephen Rothwell wrote:
> Hi John,
>
> One obvious thing ...
>
> On Wed, 30 Jul 2014 17:01:05 -0700 John Stultz
<john.stultz@linaro.org> wrote:
>>
>> diff --git a/drivers/net/wireless/ath/ath9k/hw.c
b/drivers/net/wireless/ath/ath9k/hw.c
>> index fd0158f..d15f48e 100644
>> --- a/drivers/net/wireless/ath/ath9k/hw.c
>> +++ b/drivers/net/wireless/ath/ath9k/hw.c
>> @@ -1731,19 +1731,14 @@ fail:
>>      return -EINVAL;
>>  }
>> 
>> -u32 ath9k_hw_get_tsf_offset(struct timespec *last, struct timespec *cur)
>> +u32 ath9k_hw_get_tsf_offset(ktime_t *last, ktime_t *cur)
>>  {
>> -    struct timespec ts;
>>      s64 usec;
>> 
>> -    if (!cur) {
>> -        getrawmonotonic(&ts);
>> -        cur = &ts;
>> -    }
>> -
>> -    usec = cur->tv_sec * 1000000ULL + cur->tv_nsec / 1000;
>> -    usec -= last->tv_sec * 1000000ULL + last->tv_nsec / 1000;
>> +    if (!cur)
>> +        *cur = ktime_get_raw();
>
> You are assigning through a NULL pointer here ...
Gah. That's embarrassing. Thank you. I'll fix that up.

thanks
john
