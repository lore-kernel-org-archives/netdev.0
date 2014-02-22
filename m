From: Tom Herbert <therbert@google.com>
Subject: Re: Does CHECKSUM_COMPLETE work at all?
Date: Fri, 21 Feb 2014 19:08:53 -0800
Message-ID: <CA+mtBx97w02+6iVcDxsGh4-TzsnZcjRv0+jyD=qGrCPfcWNDqg@mail.gmail.com>
References: <CA+mtBx8safaPpcntjqT+eUQBDEOxJBoVf-a9djX_qgYsSdACeA@mail.gmail.com>
	<CBA48B605613B640864883107238931C0F9077@nice.asicdesigners.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Dimitrios Michailidis <dm@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:38389 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752324AbaBVDIy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 22:08:54 -0500
Received: by mail-ig0-f177.google.com with SMTP id h3so965740igd.4
        for <netdev@vger.kernel.org>; Fri, 21 Feb 2014 19:08:54 -0800 (PST)
In-Reply-To: <CBA48B605613B640864883107238931C0F9077@nice.asicdesigners.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 21, 2014 at 6:36 PM, Dimitrios Michailidis <dm@chelsio.com> wrote:
> Tom Herbert wrote:
>> If a driver sets CHECKSUM_COMPLETE in a packet, I don't see anywhere
>> in either the Ethernet rcv path or ip_rcv where the skb->csum is being
>> pulled (no *pull_rcsum calls). I believe CHECKSUM_COMPLETE means the
>> checksum is over the whole packet (L2, L3, and L4), so it looks like
>> TCP would never see a usable value.
>>
>> Is this interpretation correct? There's only a handful of drivers
>> providing CHECKSUM_COMPLETE can anyone who has access verify this?
>
> AFAIK CHECKSUM_COMPLETE means the checksum is calculated over the L4 part of the frame but doesn't include the pseudoheader. It is completed by adding the pseudoheader.  I use it this way and it works.
>
>From skbuff.h:

"The device supplied checksum of the _whole_packet as seen by
netif_rx() and fills out in skb->csum. Meaning, the hardware doesn't
need to parse L3/L4 headers to implement this."

> By any chance are you asking this in the context of tunneling and how to get both the inner and outer checksums from the value the HW calculates?
>
Well..., I started trying to fix the UDP encapsulation code which we
agreed was broken for checksums. This also entails fixing the new UDP
GRO code to deal with checksums correctly when going through protocol
layers. But, just looking at CHECKSUM_COMPLETE it seems like it's
fundamentally broken even without encapsulation. Between GRO and HW
checksums, it seems like we have a pretty big mess! :-)

>>
>> Thanks,
>> Tom
>
