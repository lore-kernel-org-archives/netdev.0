From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] net: use jump label patching for ingress qdisc
 in __netif_receive_skb_core
Date: Sat, 11 Apr 2015 08:40:57 -0700
Message-ID: <55294089.6030202@plumgrid.com>
References: <66b2c2faaa0f629dd9a8c0981bf51f6484bc4ee9.1428699635.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, edumazet@google.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:34299 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755258AbbDKPk6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Apr 2015 11:40:58 -0400
Received: by iedfl3 with SMTP id fl3so43009822ied.1
        for <netdev@vger.kernel.org>; Sat, 11 Apr 2015 08:40:57 -0700 (PDT)
In-Reply-To: <66b2c2faaa0f629dd9a8c0981bf51f6484bc4ee9.1428699635.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/10/15 2:07 PM, Daniel Borkmann wrote:
> Even if we make use of classifier and actions from the egress
> path, we're going into handle_ing() executing additional code
> on a per-packet cost for ingress qdisc, just to realize that
> nothing is attached on ingress.
>
> Instead, this can just be blinded out as a no-op entirely with
> the use of a static key. On input fast-path, we already make
> use of static keys in various places, e.g. skb time stamping,
> in RPS, etc. It makes sense to not waste time when we're assured
> that no ingress qdisc is attached anywhere.
>
> Enabling/disabling of that code path is being done via two
> helpers, namely net_{inc,dec}_ingress_queue(), that are being
> invoked under RTNL mutex when a ingress qdisc is being either
> initialized or destructed.
>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

tested this patch standalone and with ingress_l2 on top.
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
