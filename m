From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: Re: [net-next bugfix] net, rps: fix build failure when CONFIG_RPS
 isn't set
Date: Wed, 1 Jan 2014 14:36:14 +0800
Message-ID: <CAEH94Ljf65hT4sZ4Gwx-WCh7ZprWXXSeq2b-pBuKj1EbRPYMsw@mail.gmail.com>
References: <1388521861-17410-1-git-send-email-zwu.kernel@gmail.com>
	<20131231.155459.1250298598367444558.davem@davemloft.net>
	<20131231.155839.537215284284145712.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	Fengguang Wu <fengguang.wu@intel.com>,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f45.google.com ([209.85.219.45]:40894 "EHLO
	mail-oa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750970AbaAAGgP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jan 2014 01:36:15 -0500
Received: by mail-oa0-f45.google.com with SMTP id o6so13869052oag.32
        for <netdev@vger.kernel.org>; Tue, 31 Dec 2013 22:36:15 -0800 (PST)
In-Reply-To: <20131231.155839.537215284284145712.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 1, 2014 at 4:58 AM, David Miller <davem@davemloft.net> wrote:
> From: David Miller <davem@davemloft.net>
> Date: Tue, 31 Dec 2013 15:54:59 -0500 (EST)
>
>> From: Zhi Yong Wu <zwu.kernel@gmail.com>
>> Date: Wed,  1 Jan 2014 04:31:01 +0800
>>
>>> @@ -846,12 +846,16 @@ static inline void sock_rps_reset_flow_hash(__u32 hash)
>>>
>>>  static inline void sock_rps_record_flow(const struct sock *sk)
>>>  {
>>> +#ifdef CONFIG_RPS
>>>      sock_rps_record_flow_hash(sk->sk_rxhash);
>>> +#endif
>>>  }
>>
>> Why is this necessary?  sock_rps_record_flow_hash() is provided
>> unconditionally, regardless of CONFIG_RPS.
>>
>> I'm not applying this, it doesn't make any sense.  Either there is
>> no build failure, or the existing CONFIG_RPS ifdef inside of the
>> implementation of sock_rps_record_flow_hash() is bogus.
>
> Ok, if you had actually provided the build failure log message I'd be
> able to evaluate this patch much better.
>
> The real issue is the lack of sk_rxhash when RPS is not enabled.
>
> I'm going to apply this with the build failure message mentioned.
I noticed that you have added the build failure log message in your
net-next tree.
That is, i needn't do anything now, thanks.

-- 
Regards,

Zhi Yong Wu
