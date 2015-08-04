From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] net_sched: act_bpf: remove spinlock in fast
 path
Date: Tue, 04 Aug 2015 10:55:07 +0200
Message-ID: <55C07DEB.1010902@iogearbox.net>
References: <1438664952-24712-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:36020 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755755AbbHDIzN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2015 04:55:13 -0400
In-Reply-To: <1438664952-24712-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/04/2015 07:09 AM, Alexei Starovoitov wrote:
> Similar to act_gact/act_mirred, act_bpf can be lockless in packet processing.
>
> Also similar to gact/mirred there is a race between prog->filter and
> prog->tcf_action. Meaning that the program being replaced may use
> previous default action if it happened to return TC_ACT_UNSPEC.
> act_mirred race betwen tcf_action and tcfm_dev is similar.
> In all cases the race is harmless.

Okay, what happens however, when we have an action attached to a
classifier and do a replace on that action, meaning one CPU is still
executing the filter inside tcf_bpf(), while another one is already
running tcf_bpf_cfg_cleanup() on that prog? Afaik, the schedule_work()
that's called during freeing maps/progs might 'mitigate' this race,
but doesn't give a hard guarantee, right?

> Long term we may want to improve the situation by replacing the whole
> struct tc_action as single pointer instead of updating inner fields one by one.
>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
