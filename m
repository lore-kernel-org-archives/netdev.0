From: Josh Hunt <joshhunt00@gmail.com>
Subject: Re: [PATCH v2 1/1] tcp: fixing TLP's FIN recovery
Date: Tue, 7 Oct 2014 10:03:29 -0500
Message-ID: <CAKA=qzZ+L67Z4O7DY0hR_N=5VFSZ2_Dn0to+8WLqnpfgQg+00Q@mail.gmail.com>
References: <1402583577.3645.477.camel@edumazet-glaptop2.roam.corp.google.com>
	<1402585712-12103-1-git-send-email-per.hurtig@kau.se>
	<20140612.110611.584155630422154338.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: per.hurtig@kau.se, Eric Dumazet <eric.dumazet@gmail.com>,
	panweiping3@gmail.com, nanditad@google.com, netdev@vger.kernel.org,
	anna.brunstrom@kau.se, mohammad.rajiullah@kau.se,
	ncardwell@google.com, sergei.shtylyov@cogentembedded.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f43.google.com ([209.85.192.43]:34796 "EHLO
	mail-qg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752462AbaJGPDa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 11:03:30 -0400
Received: by mail-qg0-f43.google.com with SMTP id j107so5476518qga.2
        for <netdev@vger.kernel.org>; Tue, 07 Oct 2014 08:03:29 -0700 (PDT)
In-Reply-To: <20140612.110611.584155630422154338.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 12, 2014 at 1:06 PM, David Miller <davem@davemloft.net> wrote:
> From: Per Hurtig <per.hurtig@kau.se>
> Date: Thu, 12 Jun 2014 17:08:32 +0200
>
>> Fix to a problem observed when losing a FIN segment that does not
>> contain data.  In such situations, TLP is unable to recover from
>> *any* tail loss and instead adds at least PTO ms to the
>> retransmission process, i.e., RTO = RTO + PTO.
>>
>> Signed-off-by: Per Hurtig <per.hurtig@kau.se>
>
> Applied, thanks.

Can we queue this up for stable? 2cd0d743b05e87 (tcp: fix
tcp_match_skb_to_sack() for unaligned SACK at end of an skb) is
already in stable and based on the changelog was put in place to fix a
case that this patch introduced:

"This was visible now because the recently simplified TLP logic in
 bef1909ee3ed1c ("tcp: fixing TLP's FIN recovery") could find that 0-byte
 skb at the end of the write queue, and now that we do not check that
 skb's length we could send it as a TLP probe."

However, the patch to fix TLP's FIN recovery is not in -stable.

Thanks
-- 
Josh
