From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net v2 2/4] ipv4: add defensive check for CHECKSUM_PARTIAL
 skbs in ip_fragment
Date: Tue, 27 Oct 2015 22:01:44 +0300
Message-ID: <562FCA18.8090008@cogentembedded.com>
References: <1445958135-19805-1-git-send-email-hannes@stressinduktion.org>
 <1445958135-19805-3-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, vyasevich@gmail.com, bcodding@redhat.com,
	tom@herbertland.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:34776 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964950AbbJ0TBs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 15:01:48 -0400
Received: by lbbwb3 with SMTP id wb3so71031998lbb.1
        for <netdev@vger.kernel.org>; Tue, 27 Oct 2015 12:01:47 -0700 (PDT)
In-Reply-To: <1445958135-19805-3-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 10/27/2015 06:02 PM, Hannes Frederic Sowa wrote:

> CHECKSUM_PARTIAL skbs should never arrive in ip_fragment. If we get one
> of those warn about them once and handle them gracefully by recalculating
> the checksum.
>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Vlad Yasevich <vyasevich@gmail.com>
> Cc: Benjamin Coddington <bcodding@redhat.com>
> Cc: Tom Herbert <tom@herbertland.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
>   net/ipv4/ip_output.c | 8 +++++---
>   1 file changed, 5 insertions(+), 3 deletions(-)
>
> diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
> index 0b02417..3f94a3b 100644
> --- a/net/ipv4/ip_output.c
> +++ b/net/ipv4/ip_output.c
> @@ -533,6 +533,11 @@ int ip_do_fragment(struct net *net, struct sock *sk, struct sk_buff *skb,
>
>   	dev = rt->dst.dev;
>
> +	/* for offloaded checksums cleanup checksum before fragmentation */
> +	if (WARN_ON_ONCE(skb->ip_summed == CHECKSUM_PARTIAL) &&
> +	    (err = skb_checksum_help(skb)))

    scripts/checkpatch.pl shou;d have complained about using = in the *if* 
expression.

> +		goto fail;
> +
>   	/*
>   	 *	Point into the IP datagram header.
>   	 */
[...]

MBR, Sergei
