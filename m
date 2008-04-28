From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RESEND][NETFILTER][PATCH] nfqnl_mangle() not requesting enough
 space for bigger reinjected packet.
Date: Mon, 28 Apr 2008 23:56:02 +0200
Message-ID: <481647F2.20507@trash.net>
References: <87abjdvpiq.fsf@natisbad.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Arnaud Ebalard <arno@natisbad.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33157 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934016AbYD1V4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2008 17:56:05 -0400
In-Reply-To: <87abjdvpiq.fsf@natisbad.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arnaud Ebalard wrote:
> Hi,
>
> This is a resend, first post was to netdev only and slipped through.
>
> While reinjecting *bigger* modified versions of IPv6 packets using
> libnetfilter_queue, things work fine on a 2.6.24 kernel (2.6.22 too)
> but I get the following on recents kernels (2.6.25, trace below is
> against today's net-2.6 git tree):
>
> skb_over_panic: text:c04fddb0 len:696 put:632 head:f7592c00 data:f7592c00 tail:0xf7592eb8 end:0xf7592e80 dev:eth0
> [...]
> Looking at the code, I ended up in nfq_mangle() function (called by
> nfqnl_recv_verdict()) which performs a call to skb_copy_expand() due to
> the increased size of data passed to the function. AFAICT, it should ask
> for 'diff' instead of 'diff - skb_tailroom(e->skb)'. Because the
> resulting sk_buff has not enough space to support the skb_put(skb, diff)
> call a few lines later, this results in the call to skb_over_panic().
>
> The patch below asks for allocation of a copy with enough space for
> mangled packet and the same amount of headroom as old sk_buff. While
> looking at how the regression appeared (e2b58a67), I noticed the same
> pattern in ipq_mangle_ipv6() and ipq_mangle_ipv4(). The patch corrects
> those locations too.
>
> Tested with bigger reinjected IPv6 packets (nfqnl_mangle() path), things
> are ok (2.6.25 and today's net-2.6 git tree).
>
> Don't hesitate if I missed something.
>   

Good catch, thanks. That code seems to be very resistent against
attempts to fix it :)

Patch applied, and I'll also send it to -stable once it hits
upstream.


