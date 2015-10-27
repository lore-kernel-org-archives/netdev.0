From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCHv3 net 3/3] openvswitch: Fix skb leak using IPv6 defrag
Date: Tue, 27 Oct 2015 14:30:07 -0700
Message-ID: <CALnjE+r_fRqK99f+YkmWd3TyS-YiXcAYpN=RZTZD7210ZRz=Rw@mail.gmail.com>
References: <1445829710-11292-1-git-send-email-joestringer@nicira.com>
	<1445829710-11292-3-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, Florian Westphal <fw@strlen.de>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Andy Zhou <azhou@nicira.com>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:34898 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752677AbbJ0VaI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 17:30:08 -0400
Received: by igbkq10 with SMTP id kq10so93061566igb.0
        for <netdev@vger.kernel.org>; Tue, 27 Oct 2015 14:30:07 -0700 (PDT)
In-Reply-To: <1445829710-11292-3-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 25, 2015 at 8:21 PM, Joe Stringer <joestringer@nicira.com> wrote:
> nf_ct_frag6_gather() makes a clone of each skb passed to it, and if the
> reassembly is successful, expects the caller to free all of the original
> skbs using nf_ct_frag6_consume_orig(). This call was previously missing,
> meaning that the original fragments were never freed (with the exception
> of the last fragment to arrive).
>
> Fix this by ensuring that all original fragments except for the last
> fragment are freed via nf_ct_frag6_consume_orig(). The last fragment
> will be morphed into the head, so it must not be freed yet. Furthermore,
> retain the ->next pointer for the head after skb_morph().
>
> Fixes: 7f8a436eaa2c ("openvswitch: Add conntrack action")
> Reported-by: Florian Westphal <fw@strlen.de>
> Signed-off-by: Joe Stringer <joestringer@nicira.com>

Acked-by: Pravin B Shelar <pshelar@nicira.com>
