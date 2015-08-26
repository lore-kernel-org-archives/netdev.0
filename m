From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v2 net-next 5/5] net_sched: act_bpf: remove spinlock in
 fast path
Date: Wed, 26 Aug 2015 10:17:01 +0200
Message-ID: <55DD75FD.60509@iogearbox.net>
References: <1440558395-7765-1-git-send-email-ast@plumgrid.com> <1440558395-7765-6-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:54249 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751887AbbHZIRF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 04:17:05 -0400
In-Reply-To: <1440558395-7765-6-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/26/2015 05:06 AM, Alexei Starovoitov wrote:
> Similar to act_gact/act_mirred, act_bpf can be lockless in packet processing
> with extra care taken to free bpf programs after rcu grace period.
> Replacement of existing act_bpf (very rare) is done with synchronize_rcu()
> and final destruction is done from tc_action_ops->cleanup() callback that is
> called from tcf_exts_destroy()->tcf_action_destroy()->__tcf_hash_release() when
> bind and refcnt reach zero which is only possible when classifier is destroyed.
> Previous two patches fixed the last two classifiers (tcindex and rsvp) to
> call tcf_exts_destroy() from rcu callback.
>
> Similar to gact/mirred there is a race between prog->filter and
> prog->tcf_action. Meaning that the program being replaced may use
> previous default action if it happened to return TC_ACT_UNSPEC.
> act_mirred race betwen tcf_action and tcfm_dev is similar.
> In all cases the race is harmless.
> Long term we may want to improve the situation by replacing the whole
> tc_action->priv as single pointer instead of updating inner fields one by one.
>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

Looks good to me, thanks!

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
