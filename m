From: Andy Zhou <azhou@nicira.com>
Subject: Re: [PATCH v2 nf-next 1/6] net: untangle ip_fragment and bridge netfilter
Date: Thu, 12 Mar 2015 17:38:11 -0700
Message-ID: <CACzMAJJwWFnxk76cFdVgNsAYgDROAuu=+UtP1zVa0JbHq5QxbA@mail.gmail.com>
References: <1426179925-18220-1-git-send-email-fw@strlen.de>
	<1426179925-18220-2-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netfilter-devel@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aob139.obsmtp.com ([74.125.149.251]:39565 "HELO
	psmtp.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751391AbbCMAiT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Mar 2015 20:38:19 -0400
Received: by mail-ie0-f181.google.com with SMTP id vj10so67917278iec.0
        for <netdev@vger.kernel.org>; Thu, 12 Mar 2015 17:38:13 -0700 (PDT)
In-Reply-To: <1426179925-18220-2-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 12, 2015 at 10:05 AM, Florian Westphal <fw@strlen.de> wrote:
> Long time ago it was possible for the netfilter ip_conntrack
> core to call ip_fragment in POST_ROUTING hook.
>
> This is no longer the case, so the only case where bridge netfilter
> ends up calling ip_fragment is the direct call site in br_netfilter.c.
>
> Add ll and mtu arguments for ip_fragment and then get rid of the bridge
> netfilter specific helpers from ip_fragment.
>
> Cc: Andy Zhou <azhou@nicira.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
>  include/linux/netfilter_bridge.h | 17 -----------------
>  include/net/ip.h                 |  4 ++--
>  net/bridge/br_netfilter.c        | 23 ++++++++++++++++++++---
>  net/ipv4/ip_output.c             | 37 +++++++++++++++++++++----------------
>  4 files changed, 43 insertions(+), 38 deletions(-)
>
> diff --git a/include/linux/netfilter_bridge.h b/include/linux/netfilter_bridge.h
> index ed0d3bf..fbbd5de 100644
> --- a/include/linux/netfilter_bridge.h
> +++ b/include/linux/netfilter_bridge.h
I like this patch a lot.  The nf_brdige was confusing to me when I
looked into this area. I am happen to it is going away.

With this patch, it seems we don't need the 'dev' variable anymore,
all we need is 'net' and we can move it into the 'if' block for
sending icmp.
