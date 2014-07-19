From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net] net_sched: avoid generating same handle for u32 filters
Date: Sat, 19 Jul 2014 18:07:43 -0400
Message-ID: <53CAEC2F.4050808@mojatatu.com>
References: <1405643693-4880-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Cong Wang <cwang@twopensource.com>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:50467 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751359AbaGSWHr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jul 2014 18:07:47 -0400
Received: by mail-wi0-f177.google.com with SMTP id ho1so2356577wib.4
        for <netdev@vger.kernel.org>; Sat, 19 Jul 2014 15:07:46 -0700 (PDT)
In-Reply-To: <1405643693-4880-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/17/14 20:34, Cong Wang wrote:
> From: Cong Wang <cwang@twopensource.com>
>
> When kernel generates a handle for a u32 filter, it tries to start
> from the max in the bucket. So when we have a filter with the max (fff)
> handle, it will cause kernel always generates the same handle for new
> filters. This can be shown by the following command:
>
> 	tc qdisc add dev eth0 ingress
> 	tc filter add dev eth0 parent ffff: protocol ip pref 770 handle 800::fff u32 match ip protocol 1 0xff
> 	tc filter add dev eth0 parent ffff: protocol ip pref 770 u32 match ip protocol 1 0xff
> 	...
>
> we will get some u32 filters with same handle:
>
>   # tc filter show dev eth0 parent ffff:
> filter protocol ip pref 770 u32
> filter protocol ip pref 770 u32 fh 800: ht divisor 1
> filter protocol ip pref 770 u32 fh 800::fff order 4095 key ht 800 bkt 0
>    match 00010000/00ff0000 at 8
> filter protocol ip pref 770 u32 fh 800::fff order 4095 key ht 800 bkt 0
>    match 00010000/00ff0000 at 8
> filter protocol ip pref 770 u32 fh 800::fff order 4095 key ht 800 bkt 0
>    match 00010000/00ff0000 at 8
> filter protocol ip pref 770 u32 fh 800::fff order 4095 key ht 800 bkt 0
>    match 00010000/00ff0000 at 8
>
> handles should be unique. This patch fixes it by looking up a bitmap,
> so that can guarantee the handle is as unique as possible. For compatibility,
> we still start from 0x800.
>

No fundamental objection - question though: What happens if i was to 
specify the handle when i provision the filter?
Side note: these handles + other info are used to "route" around
hash trees for filters.

I apologize in advance if i am slow in responding; i am on travel mode.

cheers,
jamal
