From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH net v3] ipv4: allow local fragmentation in
 ip_finish_output_gso()
Date: Thu, 3 Nov 2016 22:27:51 +0200
Message-ID: <20161103222751.5ae120ed@halley>
References: <1478118977-19608-1-git-send-email-lrichard@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jtluka@redhat.com
To: Lance Richardson <lrichard@redhat.com>, fw@strlen.de,
        hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34516 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750970AbcKCU2C (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 16:28:02 -0400
Received: by mail-wm0-f65.google.com with SMTP id p190so749533wmp.1
        for <netdev@vger.kernel.org>; Thu, 03 Nov 2016 13:28:02 -0700 (PDT)
In-Reply-To: <1478118977-19608-1-git-send-email-lrichard@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Hannes, Lance,

On Wed,  2 Nov 2016 16:36:17 -0400 Lance Richardson <lrichard@redhat.com> wrote:
>  
> -	if (skb_iif && !(df & htons(IP_DF))) {
> -		/* Arrived from an ingress interface, got encapsulated, with
> -		 * fragmentation of encapulating frames allowed.
> -		 * If skb is gso, the resulting encapsulated network segments
> -		 * may exceed dst mtu.
> -		 * Allow IP Fragmentation of segments.
> -		 */
> -		IPCB(skb)->flags |= IPSKB_FRAG_SEGS;
> -	}

Thinking this over, I'm concerned of this change.

Few months back, we discussed this and got to the conclusion that in the
"ingress,tunnel,egress" scenario, segments are allowed to be
fragmented if the original inner ip packet does NOT have the DF.

See 
  https://patchwork.ozlabs.org/patch/657132/
  https://patchwork.ozlabs.org/patch/661219/

I think you expressed that those tunneled skbs already having DF set
should go through pmtu discovery.

Suggested patch unconditionally calls skb_gso_validate_mtu().

Thus we're changing behavior for "ingress,tunnel,egress" scenario of
the tunneled packets having DF set in the inner iph.

WDYT?
