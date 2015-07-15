From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next] tc: fix tc actions in case of shared skb
Date: Tue, 14 Jul 2015 17:58:15 -0700
Message-ID: <55A5B027.70604@gmail.com>
References: <55A41CE9.8050907@plumgrid.com> <55A425C4.60301@iogearbox.net> <55A43B26.1010009@plumgrid.com> <20150714.153422.914759715820927338.davem@davemloft.net> <55A59657.2050100@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, jhs@mojatatu.com, jiri@resnulli.us,
	netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f43.google.com ([209.85.218.43]:32911 "EHLO
	mail-oi0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751241AbbGOA6D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 20:58:03 -0400
Received: by oige126 with SMTP id e126so18302071oig.0
        for <netdev@vger.kernel.org>; Tue, 14 Jul 2015 17:58:02 -0700 (PDT)
In-Reply-To: <55A59657.2050100@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15-07-14 04:08 PM, Alexei Starovoitov wrote:
> On 7/14/15 3:34 PM, David Miller wrote:
>>>>> 1 get rid of burst hack for both RX and TX in pktgen (kills
>>>>> >>>performance)
>> #1 is a serious consideration if you don't come up with better ideas,
>> since an optimization is for nothing if it knowingly breaks things.
> 
> I've dug up the pktgen source from 2002 and see:
>   atomic_inc(&skb->users);
>   odev->hard_start_xmit(skb, odev);
> so it did this trick forever.
> Looks like it's a fundamental way how pktgen was working
> and working still. Even when new 'burst' feature is not used,
> pktgen still increments skb->users to hold skb.
> At present I don't have good ideas how to redesign pktgen
> and since apparently no one noticed this tc_action+pktgen
> breakage for years, it's probably ok to leave everything as-is until
> better ideas come. I'm not giving up yet. Just ran out of ideas.
> 

Right and we hit this issue when pktgen is run over any stacked device
with clone_skb set. I've always put it in the don't do this category but
a fix would be nice.

> -- 
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
