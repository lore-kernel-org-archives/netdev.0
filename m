From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [RFC PATCH v2 0/5] Add driver bpf hook for early packet drop
Date: Sat, 9 Apr 2016 10:37:51 -0400
Message-ID: <570913BF.1010007@mojatatu.com>
References: <1460090874-10497-1-git-send-email-bblanco@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tom@herbertland.com,
	alexei.starovoitov@gmail.com, ogerlitz@mellanox.com,
	daniel@iogearbox.net, brouer@redhat.com, eric.dumazet@gmail.com,
	ecree@solarflare.com, john.fastabend@gmail.com, tgraf@suug.ch,
	johannes@sipsolutions.net, eranlinuxmellanox@gmail.com,
	lorenzo@google.com
To: Brenden Blanco <bblanco@plumgrid.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:34022 "EHLO
	mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751598AbcDIOhy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Apr 2016 10:37:54 -0400
Received: by mail-io0-f195.google.com with SMTP id z133so19879204iod.1
        for <netdev@vger.kernel.org>; Sat, 09 Apr 2016 07:37:54 -0700 (PDT)
In-Reply-To: <1460090874-10497-1-git-send-email-bblanco@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-04-08 12:47 AM, Brenden Blanco wrote:
> This patch set introduces new infrastructure for programmatically
> processing packets in the earliest stages of rx, as part of an effort
> others are calling Express Data Path (XDP) [1]. Start this effort by
> introducing a new bpf program type for early packet filtering, before even
> an skb has been allocated.
>
> With this, hope to enable line rate filtering, with this initial
> implementation providing drop/allow action only.
>
> Patch 1 introduces the new prog type and helpers for validating the bpf
> program. A new userspace struct is defined containing only len as a field,
> with others to follow in the future.
> In patch 2, create a new ndo to pass the fd to support drivers.
> In patch 3, expose a new rtnl option to userspace.
> In patch 4, enable support in mlx4 driver. No skb allocation is required,
> instead a static percpu skb is kept in the driver and minimally initialized
> for each driver frag.
> In patch 5, create a sample drop and count program. With single core,
> achieved ~20 Mpps drop rate on a 40G mlx4. This includes packet data
> access, bpf array lookup, and increment.

Hrm. This doesnt sound very high (less than 50%?).
Is the driver the main overhead?
I'd be curious, for comparison, if you just dropped everything
without bpf and alternatively with tc + bpf of the same program
on the one cpu.
Numbers we had for the NUC with tc on single core were a bit higher
than 20Mpps but there was no driver overhead - so i expected
to see much higher numbers if you did it at the driver...
Note back in the day Alexey(not Alexei;->) had a built-in driver
level forwarder;
however the advantage there was derived out of packets being DMAed
from ingress to egress port after some simple lookup.

cheers,
jamal
