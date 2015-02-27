From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH] net: do not use rcu in rtnl_dump_ifinfo()
Date: Fri, 27 Feb 2015 10:35:21 -0800
Message-ID: <CAHA+R7PRF14tvPEXHAfzZb_So4+jZkkG9BUUYBJ7QEmxsYvzsQ@mail.gmail.com>
References: <1425018776-14725-1-git-send-email-xiyou.wangcong@gmail.com>
	<1425024069.5130.10.camel@edumazet-glaptop2.roam.corp.google.com>
	<54F09A95.8000507@6wind.com>
	<1425056838.5130.27.camel@edumazet-glaptop2.roam.corp.google.com>
	<54F0A71F.3040808@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	David Miller <davem@davemloft.net>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:34494 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752839AbbB0SfW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 13:35:22 -0500
Received: by iecrp18 with SMTP id rp18so33156409iec.1
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2015 10:35:21 -0800 (PST)
In-Reply-To: <54F0A71F.3040808@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 27, 2015 at 9:19 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> On 02/27/2015 06:07 PM, Eric Dumazet wrote:
>>
>> From: Eric Dumazet <edumazet@google.com>
>>
>> We did a failed attempt in the past to only use rcu in rtnl dump
>> operations (commit e67f88dd12f6 "net: dont hold rtnl mutex during
>> netlink dump callbacks")
>>
>> Now that dumps are holding RTNL anyway, there is no need to also
>> use rcu locking, as it forbids any scheduling ability, like
>> GFP_KERNEL allocations that controlling path should use instead
>> of GFP_ATOMIC whenever possible.
>>
>> This should fix following splat Cong Wang reported :
>>
>> ===============================
>
>
> [ Btw, I think patchwork has an issue with above line when fetching
>   the mbox : it thinks commit description ends here. :(
>
>   Prefixing with a space char should help to not get it lost. ]

To save everyone's time, either fix patchwork or teach checkpatch.
