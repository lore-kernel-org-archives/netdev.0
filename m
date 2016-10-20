From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH 1/9] ipv6: implement dataplane support for rthdr type 4
 (Segment Routing Header)
Date: Thu, 20 Oct 2016 08:47:27 -0700
Message-ID: <CALx6S35QbosXL-U2iC9ZsLhFB0ArbuzVriHBw=tLqe3DSR-g9w@mail.gmail.com>
References: <1476715350-18983-1-git-send-email-david.lebrun@uclouvain.be>
 <1476715350-18983-2-git-send-email-david.lebrun@uclouvain.be>
 <CALx6S35sU+aw3UvMTknj8SjJP4O=Q-9eVV3OC640Qzces_eE7w@mail.gmail.com> <5808C0FB.2050202@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: David Lebrun <david.lebrun@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f176.google.com ([209.85.220.176]:33271 "EHLO
        mail-qk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933642AbcJTPr3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 11:47:29 -0400
Received: by mail-qk0-f176.google.com with SMTP id n189so101792161qke.0
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 08:47:28 -0700 (PDT)
In-Reply-To: <5808C0FB.2050202@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 20, 2016 at 6:04 AM, David Lebrun <david.lebrun@uclouvain.be> wrote:
> On 10/17/2016 07:01 PM, Tom Herbert wrote:
>>> > +
>>> > +       if (skb->ip_summed == CHECKSUM_COMPLETE)
>>> > +               skb->ip_summed = CHECKSUM_NONE;
>>> > +
>> Because the packet is being changed? Would it make sense to update the
>> checksum complete value based on the changes being made. Consider the
>> case that the next hop is local to the host (someone may try to
>> implement network virtualization this way).
>>
>
> Rethinking about that: even if the next hop is local, I am not sure to
> see the benefits of updating the checksum instead of setting
> CHECKSUM_NONE. For example, if the next and final hop is local and the
> packet carries a TCP payload, tcp_checksum_complete() would force the
> recomputation of the checksum anyway (unless ip_summed ==
> CHECKSUM_UNNECESSARY).
>
Or unless skb->csum_valid is set (tcp_checksum_complete calls
skb_csum_unnecessary where the check is done). If the checksum
complete value is correct then skb->csum_valid would be set from
skb_checksum_init which is called early in tcp_v4_rcv and tcp_v6_rcv.
This way if the penultimate and final hops are local and
CHECKSUM_COMPLETE is set computing the packet checksum is avoided for
a TCP packet.

Tom

> So I fail to see a path where updating the checksum would be beneficial.
>
> Am I missing something ?
>
> David
>
