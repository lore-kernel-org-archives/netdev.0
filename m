From: Tariq Toukan <ttoukan.linux@gmail.com>
Subject: Re: [PATCH v6 00/12] Add driver bpf hook for early packet drop and
 forwarding
Date: Sun, 10 Jul 2016 19:14:28 +0300
Message-ID: <02423eef-c081-df5d-5980-4cbf69cc32c0@gmail.com>
References: <1467944124-14891-1-git-send-email-bblanco@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Martin KaFai Lau <kafai@fb.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Ari Saha <as754m@att.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Or Gerlitz <gerlitz.or@gmail.com>, john.fastabend@gmail.com,
	hannes@stressinduktion.org, Thomas Graf <tgraf@suug.ch>,
	Tom Herbert <tom@herbertland.com>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Brenden Blanco <bblanco@plumgrid.com>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34609 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932411AbcGJQOe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jul 2016 12:14:34 -0400
Received: by mail-wm0-f67.google.com with SMTP id w75so13473951wmd.1
        for <netdev@vger.kernel.org>; Sun, 10 Jul 2016 09:14:33 -0700 (PDT)
In-Reply-To: <1467944124-14891-1-git-send-email-bblanco@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 08/07/2016 5:15 AM, Brenden Blanco wrote:
> This patch set introduces new infrastructure for programmatically
> processing packets in the earliest stages of rx, as part of an effort
> others are calling eXpress Data Path (XDP) [1]. Start this effort by
> introducing a new bpf program type for early packet filtering, before
> even an skb has been allocated.
>
> Extend on this with the ability to modify packet data and send back out
> on the same port.
>
> Patch 1 introduces the new prog type and helpers for validating the bpf
>    program. A new userspace struct is defined containing only data and
>    data_end as fields, with others to follow in the future.
> In patch 2, create a new ndo to pass the fd to supported drivers.
> In patch 3, expose a new rtnl option to userspace.
> In patch 4, enable support in mlx4 driver.
> In patch 5, create a sample drop and count program. With single core,
>    achieved ~20 Mpps drop rate on a 40G ConnectX3-Pro. This includes
>    packet data access, bpf array lookup, and increment.
> In patch 6, add a page recycle facility to mlx4 rx, enabled when xdp is
>    active.
> In patch 7, add the XDP_TX type to bpf.h
> In patch 8, add helper in tx patch for writing tx_desc
> In patch 9, add support in mlx4 for packet data write and forwarding
> In patch 10, turn on packet write support in the bpf verifier
> In patch 11, add a sample program for packet write and forwarding. With
>    single core, achieved ~10 Mpps rewrite and forwarding.
> In patch 12, add prefetch to mlx4 rx to bump forwarding to 12 Mpps
In general, I need some time (2-3 days) to run regression tests over 
this updated patch-set, as it does non-trivial changes to our mlx4_en 
data-path flows.
Other specific comments will be addressed separately.

Regards,
Tariq
