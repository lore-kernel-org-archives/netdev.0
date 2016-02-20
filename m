From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [Patch net-next] net_sched: add network namespace support for
 tc actions
Date: Sat, 20 Feb 2016 19:36:14 +0100
Message-ID: <56C8B21E.7070307@iogearbox.net>
References: <1455928994-9726-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:54580 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751748AbcBTSgR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Feb 2016 13:36:17 -0500
In-Reply-To: <1455928994-9726-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/20/2016 01:43 AM, Cong Wang wrote:
> Currently tc actions are stored in a per-module hashtable,
> therefore are visible to all network namespaces. This is
> probably the last part of the tc subsystem which is not
> aware of netns now. This patch makes them per-netns,
> several tc action API's need to be adjusted for this.
>
> The tc action API code is ugly due to historical reasons,
> we need to refactor that code in the future.
>
> Also this patch is on top of my other patch
> "net_sched: fix memory leaks when rmmod tc action modules",
> therefore should be applied after -net is merged into
> net-next.
>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>   include/net/act_api.h    |  28 +++++---
>   net/sched/act_api.c      |  88 ++++++++++-------------
>   net/sched/act_bpf.c      |  71 +++++++++++++++++--
>   net/sched/act_connmark.c |  73 +++++++++++++++++--
>   net/sched/act_csum.c     |  78 +++++++++++++++++++--
>   net/sched/act_gact.c     |  74 ++++++++++++++++++--
>   net/sched/act_ipt.c      | 178 +++++++++++++++++++++++++++++++++++++++++++----
>   net/sched/act_mirred.c   |  75 ++++++++++++++++++--
>   net/sched/act_nat.c      |  73 +++++++++++++++++--
>   net/sched/act_pedit.c    |  73 +++++++++++++++++--
>   net/sched/act_police.c   |  69 ++++++++++++++++--
>   net/sched/act_simple.c   |  76 ++++++++++++++++++--
>   net/sched/act_skbedit.c  |  73 +++++++++++++++++--
>   net/sched/act_vlan.c     |  73 +++++++++++++++++--
>   14 files changed, 969 insertions(+), 133 deletions(-)

Thanks for working on this!

Do you see a way to reduce the code duplication needed across all
the action modules? I.e. that each of them now needs to register
a new per netns subsystem, etc. In other words, is there a way the
action API could be reworked to handle most of this in the tc core
framework instead?

Cheers,
Daniel
