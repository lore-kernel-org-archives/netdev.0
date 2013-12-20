From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next] net_sched: fix a regression in tcf_proto_lookup_ops()
Date: Fri, 20 Dec 2013 11:11:25 -0800
Message-ID: <CAM_iQpUQ3iaq+X+CngqJCGWq5Ep_XhcfWEKqrCQcZ3iC6Uz_qA@mail.gmail.com>
References: <1387526931-21814-1-git-send-email-xiyou.wangcong@gmail.com>
	<52B434FA.8080309@mojatatu.com>
	<1387550222.19078.434.camel@edumazet-glaptop2.roam.corp.google.com>
	<52B45851.90208@mojatatu.com>
	<1387555659.19078.439.camel@edumazet-glaptop2.roam.corp.google.com>
	<1387560028.19078.442.camel@edumazet-glaptop2.roam.corp.google.com>
	<1387560578.19078.443.camel@edumazet-glaptop2.roam.corp.google.com>
	<1387562658.19078.448.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:54459 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752682Ab3LTTL0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 14:11:26 -0500
Received: by mail-ob0-f181.google.com with SMTP id uy5so3060586obc.26
        for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 11:11:25 -0800 (PST)
In-Reply-To: <1387562658.19078.448.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 20, 2013 at 10:04 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> list_for_each_entry(t, &tcf_proto_base, head) doesn't
> exit with t = NULL if we reached the end of the list.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Fixes: 3627287463b4 ("net_sched: convert tcf_proto_ops to use struct
> list_head")
> Cc: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>  net/sched/cls_api.c |   22 ++++++++++------------
>  1 file changed, 10 insertions(+), 12 deletions(-)

The bug you reported to me yesterday is in mirred action module cleanup,
so how is it possible to be fixed in cls_api.c? It should be act_api.c.

If you meant to fix a different bug, please include the backtrace in the log?

Your patch looks good generally, but actually I doubt we need to check for
an existing ops when unregistering, since we almost for sure only unregister
existing ones as they are all static allocated.
