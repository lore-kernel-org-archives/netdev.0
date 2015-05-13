From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next v2] net: core: set and refine qdisc pkt len before
 tc_classify
Date: Wed, 13 May 2015 14:07:00 -0700
Message-ID: <5553BCF4.601@plumgrid.com>
References: <1431550209-3498-1-git-send-email-daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, jhs@mojatatu.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:36442 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964810AbbEMVHB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 17:07:01 -0400
Received: by pabsx10 with SMTP id sx10so61910228pab.3
        for <netdev@vger.kernel.org>; Wed, 13 May 2015 14:07:01 -0700 (PDT)
In-Reply-To: <1431550209-3498-1-git-send-email-daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/13/15 1:50 PM, Daniel Borkmann wrote:
> From: Florian Westphal <fw@strlen.de>
>
> Commit d2788d34885d4ce5ba ("net: sched: further simplify handle_ing")
> removed the call to qdisc_enqueue_root(). However, after this removal
> we no longer set qdisc pkt length, which this patch fixes. We make use
> of qdisc_pkt_len_init() from 1def9238d4aa ("net_sched: more precise
> pkt_len computation"), which was suggested as the current approach so
> far does not take into account when GRO builds up GSO packets.
>
> Fixes: d2788d34885d ("net: sched: further simplify handle_ing")
> Suggested-by: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> ---

Looks good as quick fix for now. Long term I still want to try to reuse
stats from underlying netdev ;)
For TX we don't have this option and have to do qdisc_pkt_len_init(),
but for RX we should be able to do something smarter.

Acked-by: Alexei Starovoitov <ast@plumgrid.com>
