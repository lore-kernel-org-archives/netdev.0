From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH -next] net: core: set qdisc pkt len before tc_classify
Date: Wed, 13 May 2015 07:07:47 -0400
Message-ID: <55533083.6070504@mojatatu.com>
References: <1431437838-5478-1-git-send-email-fw@strlen.de> <1431440547.566.84.camel@edumazet-glaptop2.roam.corp.google.com> <20150512151646.GB22387@breakpoint.cc> <20150512170322.GA3524@Alexeis-MBP.westell.com> <55532F5A.5070007@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	daniel@iogearbox.net
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:37211 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753963AbbEMLHt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 07:07:49 -0400
Received: by igbsb11 with SMTP id sb11so41299521igb.0
        for <netdev@vger.kernel.org>; Wed, 13 May 2015 04:07:48 -0700 (PDT)
In-Reply-To: <55532F5A.5070007@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/13/15 07:02, Jamal Hadi Salim wrote:
>
>
> I dont think we need the stab on the ingress but we do need to account
> for gso. So option #1 with qdisc_pkt_len_init() alone is the only thing
> needed. i.e Florian's change becomes:
>
> -    qdisc_bstats_update_cpu(cl->q, skb);
> +    qdisc_pkt_len_init(skb)
>       skb->tc_verd = SET_TC_AT(skb->tc_verd, AT_INGRESS);
> +    qdisc_bstats_update_cpu(cl->q, skb);
>
> Alexei, why do you say this option will have overhead?
>

and the comment in qdisc_pkt_len_init() needs fixing too.
It says:
         /* To get more precise estimation of bytes sent on wire,
          * we add to pkt_len the headers size of all segments
          */


It implies transmit direction only - modern nics do set this
on receive.  Something like:

         /* To get more precise estimation of bytes rx or to be sent
           on the wire, we add to pkt_len the headers size of
           all segments
         */

cheers,
jamal
