From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH] bridge: only provide proxy ARP when CONFIG_INET is enabled
Date: Tue, 13 Jan 2015 14:14:20 -0700
Message-ID: <54B58AAC.7090001@gmail.com>
References: <56868207.rHBDZL3pbk@wuerfel>	<CAHA+R7NfZMRMJ2=pq-VYU_FRdcCheAYu9OW6Hj9fwB0mcT7Xng@mail.gmail.com> <20150113.155740.1237959632603319909.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kyeyoonp@codeaurora.org,
	bridge@lists.linux-foundation.org, stephen@networkplumber.org
To: David Miller <davem@davemloft.net>, cwang@twopensource.com,
	arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:48320 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750848AbbAMVOW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 16:14:22 -0500
Received: by mail-pa0-f45.google.com with SMTP id lf10so5922630pab.4
        for <netdev@vger.kernel.org>; Tue, 13 Jan 2015 13:14:22 -0800 (PST)
In-Reply-To: <20150113.155740.1237959632603319909.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/13/15 1:57 PM, David Miller wrote:
> From: Cong Wang <cwang@twopensource.com>
> Date: Tue, 13 Jan 2015 11:25:45 -0800
>
>> On Tue, Jan 13, 2015 at 6:10 AM, Arnd Bergmann <arnd@arndb.de> wrote:
>>> When IPV4 support is disabled, we cannot call arp_send from
>>> the bridge code, which would result in a kernel link error:
>>>
>>> net/built-in.o: In function `br_handle_frame_finish':
>>> :(.text+0x59914): undefined reference to `arp_send'
>>> :(.text+0x59a50): undefined reference to `arp_tbl'
>>>
>>> This makes the newly added proxy ARP support in the bridge
>>> code depend on the CONFIG_INET symbol and lets the compiler
>>> optimize the code out to avoid the link error.
>>>
>>
>> Not sure how much sense to make CONFIG_BRIDGE depend
>> on CONFIG_INET, at least CONFIG_BONDING does.
>
> It depends upon whether we want to provide and consider
> as a valid configuration bridging without INET.  Probably
> we do.

Rather than connect CONFIG_BRIDGE to CONFIG_INET, why not make 
br_do_proxy_arp (and setting BR_PROXYARP flag) a no-op if CONFIG_INET is 
not set?

#ifdef CONFIG_INET
#else
static inline void br_do_proxy_arp(...args...)
{
}
#endif

That covers both arp_tbl and arp_send.

David
