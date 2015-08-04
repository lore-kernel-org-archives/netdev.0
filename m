From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] net_sched: act_bpf: remove spinlock in fast path
Date: Tue, 4 Aug 2015 09:35:21 -0700
Message-ID: <55C0E9C9.3070907@plumgrid.com>
References: <1438664952-24712-1-git-send-email-ast@plumgrid.com>
 <55C07DEB.1010902@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:35908 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752542AbbHDQfY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2015 12:35:24 -0400
Received: by pacgq8 with SMTP id gq8so12349791pac.3
        for <netdev@vger.kernel.org>; Tue, 04 Aug 2015 09:35:23 -0700 (PDT)
In-Reply-To: <55C07DEB.1010902@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/4/15 1:55 AM, Daniel Borkmann wrote:
> Okay, what happens however, when we have an action attached to a
> classifier and do a replace on that action, meaning one CPU is still
> executing the filter inside tcf_bpf(), while another one is already
> running tcf_bpf_cfg_cleanup() on that prog? Afaik, the schedule_work()
> that's called during freeing maps/progs might 'mitigate' this race,
> but doesn't give a hard guarantee, right?

ahh, yes, that's completely different race. tcf_bpf_cfg_cleanup should
be doing call_rcu.
Will respin the patch.
