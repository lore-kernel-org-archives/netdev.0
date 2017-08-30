From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [Patch net-next] net_sched: add reverse binding for tc class
Date: Wed, 30 Aug 2017 23:48:40 +0200
Message-ID: <59A732B8.6020405@iogearbox.net>
References: <20170830213036.24250-1-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:52367 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750824AbdH3Vsl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 17:48:41 -0400
In-Reply-To: <20170830213036.24250-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/30/2017 11:30 PM, Cong Wang wrote:
[...]
> Note, we still can NOT totally get rid of those class lookup in
> ->enqueue() because cgroup and flow filters have no way to determine
> the classid at setup time, they still have to go through dynamic lookup.
[...]
> ---
>   include/net/sch_generic.h |  1 +
>   net/sched/cls_basic.c     |  9 +++++++
>   net/sched/cls_bpf.c       |  9 +++++++

Same is for cls_bpf as well, so bind_class wouldn't work there
either as we could return dynamic classids. bind_class cannot
be added here, too.

>   net/sched/cls_flower.c    |  9 +++++++
>   net/sched/cls_fw.c        |  9 +++++++
>   net/sched/cls_matchall.c  |  9 +++++++
>   net/sched/cls_route.c     |  9 +++++++
>   net/sched/cls_rsvp.h      |  9 +++++++
>   net/sched/cls_tcindex.c   |  9 +++++++
>   net/sched/cls_u32.c       |  9 +++++++
>   net/sched/sch_api.c       | 68 +++++++++++++++++++++++++++++++++++++++++++++--
>   11 files changed, 148 insertions(+), 2 deletions(-)
