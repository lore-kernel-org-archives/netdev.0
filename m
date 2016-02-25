From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v2 0/3] tc software only flag
Date: Thu, 25 Feb 2016 15:24:33 -0800
Message-ID: <56CF8D31.3070307@gmail.com>
References: <20160225231540.9820.7688.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
	davem@davemloft.net, jhs@mojatatu.com
To: jiri@resnulli.us, daniel@iogearbox.net, simon.horman@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:35389 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752219AbcBYXYq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 18:24:46 -0500
Received: by mail-pf0-f172.google.com with SMTP id c10so42137399pfc.2
        for <netdev@vger.kernel.org>; Thu, 25 Feb 2016 15:24:45 -0800 (PST)
In-Reply-To: <20160225231540.9820.7688.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-25 03:19 PM, John Fastabend wrote:
> This adds a software only flag to tc but incorporates a bunch of comments
> from the original attempt at this.

In case its not entirely obvious I dropped the hardware only case for
now because I'm investigating Jiri's comment. But just having the
software only case lets me handle many use cases. Now in the u32
classifier I can build graphs where part of the graph is software only
and other parts are sw/hw. This lets me use part of the mark bit or
queue information to learn if the hardware has already acted on the
skb and then parse it differently in the classifier.

> 
> First instead of having the offload decision logic be embedded in cls_u32
> I lifted into cls_pkt.h so it can be used anywhere.
> 
> In order to do this I put the flag defines in pkt_cls.h as well. However
> it was suggested that perhaps these flags could be lifted into the
> upper layer of TCA_ as well but I'm afraid this can not be done with
> existing tc design as far as I can tell. The problem is the filters are
> packed and unpacked in the classifier specific code and pushing the flags
> through the high level doesn't seem easily doable. And we already have
> this design where classifiers handle generic options such as actions and
> policers. So I think adding one more thing here is OK as 'tc', et. al.
> already know how to handle this type of thing.
> 
> Thanks,
> .John
> 
> ---
> 
> John Fastabend (3):
>       net: sched: consolidate offload decision in cls_u32
>       net: cls_u32: move TC offload feature bit into cls_u32 offload logic
>       net: sched: cls_u32 add bit to specify software only rules
> 
> 
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    3 --
>  include/net/pkt_cls.h                         |   17 +++++++++++
>  include/uapi/linux/pkt_cls.h                  |    1 +
>  net/sched/cls_u32.c                           |   37 ++++++++++++++++++-------
>  4 files changed, 45 insertions(+), 13 deletions(-)
> 
> --
> Signature
> 
