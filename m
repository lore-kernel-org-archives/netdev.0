From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH] flow-dissector: Fix alignment issue in __skb_flow_get_ports
Date: Fri, 10 Oct 2014 11:02:04 -0700
Message-ID: <54381F1C.2030800@gmail.com>
References: <5437F7CB.5010101@redhat.com>	<1412954973.9362.11.camel@edumazet-glaptop2.roam.corp.google.com>	<54380E49.5050504@redhat.com> <20141010.135851.1743803688676076555.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, David.Laight@ACULAB.COM,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, alexander.h.duyck@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:54171 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755215AbaJJSCF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 14:02:05 -0400
Received: by mail-pa0-f53.google.com with SMTP id kq14so2132349pab.26
        for <netdev@vger.kernel.org>; Fri, 10 Oct 2014 11:02:04 -0700 (PDT)
In-Reply-To: <20141010.135851.1743803688676076555.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/10/2014 10:58 AM, David Miller wrote:
> From: Alexander Duyck <alexander.h.duyck@redhat.com>
> Date: Fri, 10 Oct 2014 09:50:17 -0700
>
>> If I just use get_unaligned that is pretty easy in terms of cleanup
>> for the ports and IPv4 addresses, the IPv6 will still be a significant
>> hurdle to overcome though.
> Actually, it's not that simple.
>
> When the compiler sees things like "th->doff" it will load the 32-bit
> word that 4-bit field contains and extract the value using shifts and
> masking.
>
> So we might need to sprinkle a "attribute((packed))" here and there
> to make it work.

I'll do some digging.  I know I had this working in igb/ixgbe before so
I probably just need to add a few small tweaks to resolve the remaining
issues for v4 of the patch.

Thanks,

Alex
