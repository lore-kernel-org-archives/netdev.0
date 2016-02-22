From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [net-next PATCH 0/5] net_sched: Add support for IFE action
Date: Mon, 22 Feb 2016 17:47:12 +0100
Message-ID: <56CB3B90.8030206@iogearbox.net>
References: <1456147304-13355-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
	alexei.starovoitov@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:37755 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751318AbcBVQrQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2016 11:47:16 -0500
In-Reply-To: <1456147304-13355-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jamal,

On 02/22/2016 02:21 PM, Jamal Hadi Salim wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>
>
>
> As agreed at netconf in Seville, here's the patch finally (1 year
> was just too long to wait).
> Described in netdev01 paper:
>              "Distributing Linux Traffic Control Classifier-Action Subsystem"
>               Authors: Jamal Hadi Salim and Damascene M. Joachimpillai
>
> Allows for incremental updates for new metadatum support.
> This patch set includes support for basic skb metadatum
> Followup patches will have more examples of metadata

So, basically this is a L2 encap with TLVs, right?

And as TLVs you have skb->mark, skb->priority, skb->hash, skb->queue_mapping
that you transfer from one machine to another, where on the destination, you
are applying the above meta data to the skb itself. And, configuration is via
tc.

I couldn't parse from the commit log what the real world use case is, resp.
who is going to use this infrastructure?

Do you have some typical setup, where the above needs to be transferred in the
encap and restored?

> Jamal Hadi Salim (5):
>    introduce IFE action
>    Support to encoding decoding skb mark on IFE action
>    Support to encoding decoding skb prio on IFE action
>    Support to encoding decoding skb hashid on IFE action
>    Support to encoding decoding skb queue map on IFE action
>
>   include/net/tc_act/tc_ife.h        |  60 +++
>   include/uapi/linux/tc_act/tc_ife.h |  38 ++
>   net/sched/Kconfig                  |  32 ++
>   net/sched/Makefile                 |   5 +
>   net/sched/act_ife.c                | 865 +++++++++++++++++++++++++++++++++++++
>   net/sched/act_meta_mark.c          |  81 ++++
>   net/sched/act_meta_qmap.c          | 100 +++++
>   net/sched/act_meta_skbhash.c       |  87 ++++
>   net/sched/act_meta_skbprio.c       |  80 ++++

Splitting these set/get functions into individual modules where you only
set/get a single skb member seems overkill to me. Could be done with a
simple switch statement inside ife?

>   9 files changed, 1348 insertions(+)
>   create mode 100644 include/net/tc_act/tc_ife.h
>   create mode 100644 include/uapi/linux/tc_act/tc_ife.h
>   create mode 100644 net/sched/act_ife.c
>   create mode 100644 net/sched/act_meta_mark.c
>   create mode 100644 net/sched/act_meta_qmap.c
>   create mode 100644 net/sched/act_meta_skbhash.c
>   create mode 100644 net/sched/act_meta_skbprio.c

Thanks,
Daniel
