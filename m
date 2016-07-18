From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 1/1] net_sched: Introduce skbmod action
Date: Sun, 17 Jul 2016 21:19:35 -0700
Message-ID: <20160718041933.GB36253@ast-mbp.thefacebook.com>
References: <1468744884-8246-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, daniel@iogearbox.net,
	xiyou.wangcong@gmail.com, nikolay@cumulusnetworks.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:36551 "EHLO
	mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750709AbcGRETm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 00:19:42 -0400
Received: by mail-pa0-f65.google.com with SMTP id ez1so6874684pab.3
        for <netdev@vger.kernel.org>; Sun, 17 Jul 2016 21:19:42 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1468744884-8246-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 17, 2016 at 04:41:24AM -0400, Jamal Hadi Salim wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>
> 
> This action is intended to be an upgrade from a usability perspective
> from pedit (as well as operational debugability).
> Compare this:
> 
> sudo tc filter add dev $ETH parent 1: protocol ip prio 10 \
> u32 match ip protocol 1 0xff flowid 1:2 \
> action pedit munge offset -14 u8 set 0x02 \
>     munge offset -13 u8 set 0x15 \
>     munge offset -12 u8 set 0x15 \
>     munge offset -11 u8 set 0x15 \
>     munge offset -10 u16 set 0x1515 \
>     pipe
> 
> to:
> 
> sudo tc filter add dev $ETH parent 1: protocol ip prio 10 \
> u32 match ip protocol 1 0xff flowid 1:2 \
> action skbmod dmac 02:15:15:15:15:15
> 
> Or worse, try to debug a policy with destination mac, source mac and
> etherype. Then make that a hundred rules and you'll get my point.
> 
> In the future common use cases on pedit can be migrated to this action
> (as an example different fields in ip v4/6, transports like tcp/udp/sctp
> etc). For this first cut, this allows modifying basic ethernet header.
> 
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
> ---
>  include/net/tc_act/tc_skbmod.h        |  35 +++++
>  include/uapi/linux/tc_act/tc_skbmod.h |  47 +++++++
>  net/sched/Kconfig                     |  11 ++
>  net/sched/Makefile                    |   1 +
>  net/sched/act_skbmod.c                | 245 ++++++++++++++++++++++++++++++++++
>  5 files changed, 339 insertions(+)
>  create mode 100644 include/net/tc_act/tc_skbmod.h
>  create mode 100644 include/uapi/linux/tc_act/tc_skbmod.h
>  create mode 100644 net/sched/act_skbmod.c

I agree with Cong's point that this new action adds 339 lines of kernel
code without adding any new functionality.
It is suppose to solve debugging issues, but it's hard to understand
from commit log.
I can imagine new tc command 'action skbmod dmac 02:15:15:15:15:15' that
uses kernel pedit action undercover, so from user space point of view
the same effect can be achieved by extending iproute2.
What is the reason to add this action to the kernel?
By debug you mean to dump kernel action list and multiple pedits
are hard to decipher? Anything else I'm missing?
