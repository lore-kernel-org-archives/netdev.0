From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Questions about CHECKSUM_COMPLETE
Date: Fri, 21 Oct 2011 13:09:34 +0100
Message-ID: <1319198974.2918.35.camel@deadeye>
References: <CAF5V5FbthBZ3QFzCUVov8MZ9TgF=+B6XM3eR+cyizbzcT-6v-A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fengcheng lu <sparking.lu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:21111 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754587Ab1JUMJq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2011 08:09:46 -0400
In-Reply-To: <CAF5V5FbthBZ3QFzCUVov8MZ9TgF=+B6XM3eR+cyizbzcT-6v-A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-10-20 at 23:05 -0400, fengcheng lu wrote:
> Hello everyone
> 
> I have one question about the CHECKSUM_COMPLETE. When
> CHECK_SUM_COMPLETE is set, which data does the skb->csum computed by
> hardware cover?
> 
> I thought skb->csum only covers the Transport header (e.g. TCP/UDP) +
> Transport payload + pseudo header. However, after I read the vlan
> codes (vlan_skb_recv in the vlan_dev.c of linux kernel 2.6.27.19), I
> become confuse.
> 
> The vlan_skb_recv calls skb_pull_rcsum which updates the skb->csum if
> CHECKSUM_COMPLETE is set. It implies the vlan  header is also covered
> by the skb->csum. so I wonder if the skb->csum cover the whole data
> besides the eth header (14 bytes).

That's right, it's supposed to cover the complete packet (as seen by
Linux, so not including an Ethernet CRC).  The hardware doesn't need to
parse L3/L4 headers to implement this.

If the hardware you're dealing with doesn't calculate the full checksum
but it does parse headers and verify checksums for specific protocols
then you can set ip_summed = CHECKSUM_UNNECESSARY if the checksums are
OK.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
