From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/4] net: Rename rxhash to hash
Date: Mon, 24 Mar 2014 15:06:45 -0700
Message-ID: <1395698805.12610.78.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.DEB.2.02.1403201659350.6989@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:53593 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751078AbaCXWGr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2014 18:06:47 -0400
Received: by mail-pa0-f42.google.com with SMTP id fb1so6066938pad.15
        for <netdev@vger.kernel.org>; Mon, 24 Mar 2014 15:06:47 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.02.1403201659350.6989@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-03-20 at 17:09 -0700, Tom Herbert wrote:
> The packet hash can be considered a property of the packet, not just
> on RX path.
> 
> This patch changes name of rxhash and l4_rxhash skbuff fields to be
> hash and l4_hash respectively. This includes changing uses of the
> field in the code which don't call the access functions.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  arch/s390/net/bpf_jit_comp.c |  8 ++++----
>  include/linux/skbuff.h       | 28 ++++++++++++++--------------
>  include/net/sock.h           |  4 ++--
>  include/trace/events/net.h   | 12 ++++++------
>  net/core/dev.c               | 11 ++++++-----
>  net/core/filter.c            |  2 +-
>  net/core/flow_dissector.c    | 10 +++++-----
>  net/packet/af_packet.c       |  2 +-
>  8 files changed, 39 insertions(+), 38 deletions(-)


It looks like you missed 

arch/arm/net/bpf_jit_32.c:			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, rxhash) != 4);
arch/arm/net/bpf_jit_32.c:			off = offsetof(struct sk_buff, rxhash);
arch/powerpc/net/bpf_jit_comp.c:			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, rxhash) != 4);
arch/powerpc/net/bpf_jit_comp.c:							  rxhash));
arch/sparc/net/bpf_jit_comp.c:				emit_skb_load32(rxhash, r_A);
arch/x86/net/bpf_jit_comp.c:				BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, rxhash) != 4);
arch/x86/net/bpf_jit_comp.c:				if (is_imm8(offsetof(struct sk_buff, rxhash))) {
arch/x86/net/bpf_jit_comp.c:					EMIT3(0x8b, 0x47, offsetof(struct sk_buff, rxhash));
arch/x86/net/bpf_jit_comp.c:					EMIT(offsetof(struct sk_buff, rxhash), 4);
