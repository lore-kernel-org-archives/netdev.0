From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] tc: fix tc actions in case of shared skb
Date: Tue, 14 Jul 2015 16:08:07 -0700
Message-ID: <55A59657.2050100@plumgrid.com>
References: <55A41CE9.8050907@plumgrid.com> <55A425C4.60301@iogearbox.net>
 <55A43B26.1010009@plumgrid.com>
 <20150714.153422.914759715820927338.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, jhs@mojatatu.com, jiri@resnulli.us,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34773 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752939AbbGNXIJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 19:08:09 -0400
Received: by pacan13 with SMTP id an13so12774154pac.1
        for <netdev@vger.kernel.org>; Tue, 14 Jul 2015 16:08:09 -0700 (PDT)
In-Reply-To: <20150714.153422.914759715820927338.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/14/15 3:34 PM, David Miller wrote:
>>>> 1 get rid of burst hack for both RX and TX in pktgen (kills
>>>> >>>performance)
> #1 is a serious consideration if you don't come up with better ideas,
> since an optimization is for nothing if it knowingly breaks things.

I've dug up the pktgen source from 2002 and see:
   atomic_inc(&skb->users);
   odev->hard_start_xmit(skb, odev);
so it did this trick forever.
Looks like it's a fundamental way how pktgen was working
and working still. Even when new 'burst' feature is not used,
pktgen still increments skb->users to hold skb.
At present I don't have good ideas how to redesign pktgen
and since apparently no one noticed this tc_action+pktgen
breakage for years, it's probably ok to leave everything as-is until
better ideas come. I'm not giving up yet. Just ran out of ideas.
