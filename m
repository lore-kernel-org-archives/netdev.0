From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 -next] ingress, clsact: don't add TCA_OPTIONS
 to nl msg
Date: Mon, 16 May 2016 11:22:37 -0700
Message-ID: <20160516112237.2e1fb0b9@xeon-e3>
References: <192c686bb5e277b9552fe1e5c39b14bed520dddd.1463329895.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, tgraf@suug.ch, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:34457 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750729AbcEPSWY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 14:22:24 -0400
Received: by mail-pf0-f176.google.com with SMTP id y69so69510327pfb.1
        for <netdev@vger.kernel.org>; Mon, 16 May 2016 11:22:24 -0700 (PDT)
In-Reply-To: <192c686bb5e277b9552fe1e5c39b14bed520dddd.1463329895.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 15 May 2016 18:36:03 +0200
Daniel Borkmann <daniel@iogearbox.net> wrote:

> In ingress and clsact qdisc TCA_OPTIONS are ignored, since it's
> parameterless. In tc, we add an empty addattr_l(... TCA_OPTIONS,
> NULL, 0) to the netlink message nevertheless. This has the
> side effect that when someone tries a 'tc qdisc replace' and
> already an existing such qdisc is present, tc fails with
> EINVAL here.
> 
> Reason is that in the kernel, this invokes qdisc_change() when
> such requested qdisc is already present. When TCA_OPTIONS are
> passed to modify parameters, it looks whether qdisc implements
> .change() callback, and if not present (like in both cases here)
> it returns with error. Rather than adding an empty stub to the
> kernel that ignores TCA_OPTIONS again, just don't add TCA_OPTIONS
> to the netlink message in the first place.
> 
> Before:
> 
>   # tc qdisc replace dev foo clsact    # first try
>   # tc qdisc replace dev foo clsact    # second one
>   RTNETLINK answers: Invalid argument
> 
> After:
> 
>   # tc qdisc replace dev foo clsact
>   # tc qdisc replace dev foo clsact
>   # tc qdisc replace dev foo clsact
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> ---
>  tc/q_clsact.c  | 1 -
>  tc/q_ingress.c | 1 -
>  2 files changed, 2 deletions(-)

Applied to net-next
