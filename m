From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next v2] net: core: set and refine qdisc pkt len before
 tc_classify
Date: Wed, 13 May 2015 23:36:49 +0200
Message-ID: <5553C3F1.4070208@iogearbox.net>
References: <1431550209-3498-1-git-send-email-daniel@iogearbox.net> <1431552055.27831.17.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, fw@strlen.de, ast@plumgrid.com,
	jhs@mojatatu.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:53959 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965321AbbEMVg6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 17:36:58 -0400
In-Reply-To: <1431552055.27831.17.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/13/2015 11:20 PM, Eric Dumazet wrote:
...
> Is qdisc_pkt_len_init() still inlined, now it has 2 callers ?
>
> People using policers on ingress are very often disabling GRO for
> various historical reasons.

Yes, tested policer and for getting it working on my side, GRO needs
to be off.

> Since handle_ing() is very uncommon, I would prefer not slowing down tx
> just so that GRO ~5% error in ingress is fixed.

I see a callq dc0 <qdisc_pkt_len_init> now. Ok, in that case Florian's
original version is fine:

   http://patchwork.ozlabs.org/patch/471346/

> I noticed you did not CC me, don't be afraid to include me next time one
> of my commit is referred in a changelog ;)

Hmm, I did Cc you. ;)

To:	davem@davemloft.net
Cc:	fw@strlen.de, ast@plumgrid.com, jhs@mojatatu.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	daniel@iogearbox.net

Thanks,
Daniel
