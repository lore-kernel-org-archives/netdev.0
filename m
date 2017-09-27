From: =?gb2312?B?0c+6o8ur?= <yanhaishuang@cmss.chinamobile.com>
Subject: Re: [PATCH v4 2/3] ipv4: Namespaceify tcp_fastopen_key knob
Date: Wed, 27 Sep 2017 09:05:53 +0800
Message-ID: <7216AFA7-24B9-4DCD-B3D5-AFDE739E7036@cmss.chinamobile.com>
References: <1506088124-12650-2-git-send-email-yanhaishuang@cmss.chinamobile.com>
 <20170925.162445.234890912211240693.davem@davemloft.net>
 <F9EA5C4F-2306-4BC5-923A-3AB1D8F50FF1@cmss.chinamobile.com>
 <20170926.111851.1172660559080066162.davem@davemloft.net>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=gb2312
Content-Transfer-Encoding: 8BIT
Cc: kuznet@ms2.inr.ac.ru, edumazet@google.com, weiwan@google.com,
        lucab@debian.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170926.111851.1172660559080066162.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> On 2017年9月27日, at 上午2:18, David Miller <davem@davemloft.net> wrote:
> 
> From: 严海双 <yanhaishuang@cmss.chinamobile.com>
> Date: Tue, 26 Sep 2017 09:25:51 +0800
> 
>>> On 2017年9月26日, at 上午7:24, David Miller <davem@davemloft.net> wrote:
>>> 
>>> From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
>>> Date: Fri, 22 Sep 2017 21:48:43 +0800
>>> 
>>>> @@ -9,13 +9,18 @@
>>>> #include <net/inetpeer.h>
>>>> #include <net/tcp.h>
>>>> 
>>>> -struct tcp_fastopen_context __rcu *tcp_fastopen_ctx;
>>>> -
>>>> -static DEFINE_SPINLOCK(tcp_fastopen_ctx_lock);
>>>> -
>>>> -void tcp_fastopen_init_key_once(bool publish)
>>>> +void tcp_fastopen_init_key_once(struct net *net)
>>> 
>>> Why did you remove the 'publish' logic from this function?
>>> 
>> 
>> I think this logic is not necessary now, in proc_tcp_fastopen_key, I have removed 
>> tcp_fastopen_init_key_once(false) where the ‘publish’ is false:
>> 
>> -		/* Generate a dummy secret but don't publish it. This
>> -		 * is needed so we don't regenerate a new key on the
>> -		 * first invocation of tcp_fastopen_cookie_gen
>> -		 */
>> -		tcp_fastopen_init_key_once(false);
>> -		tcp_fastopen_reset_cipher(user_key, TCP_FASTOPEN_KEY_LENGTH);
>> +		tcp_fastopen_reset_cipher(net, user_key, TCP_FASTOPEN_KEY_LENGTH);
>> 
>> It said we don't regenerate a new key on first invocation of tcp_fastopen_cookie_gen, 
>> but in tcp_fastopen_cookie_gen，it didn’t  call tcp_fastopen_init_key_once since
>> from commit dfea2aa654243 (tcp: Do not call tcp_fastopen_reset_cipher from interrupt context)：
>> 
>> And in other places where call tcp_fastopen_init_key_once, the ‘publish’ is always true:
> 
> Ok, this simplification seems legitimate.
> 
> But it is unrelated to this namespacification.  So it should be in a separate patch,
> and should be documented well in the commit message using the great explanation you
> gave to me above.
> 
> Please respin this series, with this patch #2 split up into two changes.
> 
> Thank you.

Okay， thanks David for advise. I will split the patch #2 in next commit.
