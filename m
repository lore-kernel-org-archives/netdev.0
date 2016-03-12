From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH -next] bridge: fix potential use-after-free when hook
 returns QUEUE or STOLEN verdict
Date: Sat, 12 Mar 2016 22:20:08 +0300
Message-ID: <56E46BE8.7070403@cogentembedded.com>
References: <1457777682-24689-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, Felix Fietkau <nbd@openwrt.org>,
	Zefir Kurtisi <zefir.kurtisi@neratec.com>
To: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:32961 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751254AbcCLTUM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Mar 2016 14:20:12 -0500
Received: by mail-lb0-f169.google.com with SMTP id k15so195778236lbg.0
        for <netdev@vger.kernel.org>; Sat, 12 Mar 2016 11:20:11 -0800 (PST)
In-Reply-To: <1457777682-24689-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 03/12/2016 01:14 PM, Florian Westphal wrote:

> Zefir Kurtisi reported kernel panic with an openwrt specific patch.
> However, it turns out that mainline has a similar bug waiting to happen.
>
> Once NF_HOOK() returns the skb is in undefined state and must not be
> used.   Moreover, the okfn must consume the skb to support async
> processing (NF_QUEUE).
>
> Current okfn in this spot doesn't consume it and caller assumes that
> NF_HOOK return value tells us if skb was freed or not, but thats wrong.

    That's.

> It "works" because no in-tree user registers a NFPROTO_BRIDGE hook at
> LOCAL_IN that returns STOLEN or NF_QUEUE verdicts.
>
> Once we add NF_QUEUE support for nftables bridge this will break --
> NF_QUEUE holds the skb for async processing, caller will erronoulsy

    Erroneously.

> return RX_HANDLER_PASS and on reinject netfilter will access free'd skb.
>
> Fix this by pushing skb up the stack in the okfn instead.
>
> NB: It also seems dubious to use LOCAL_IN while bypassing PRE_ROUTING
> completely in this case but this is how its been forever so it seems
> preferable to not change this.
>
> Cc: Felix Fietkau <nbd@openwrt.org>
> Cc: Zefir Kurtisi <zefir.kurtisi@neratec.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>
[...]

MBR, Sergei
