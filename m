From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [RFC 4/9] ipv6: sr: add support for SRH encapsulation and injection
 with lwtunnels
Date: Mon, 29 Aug 2016 07:52:40 -0700
Message-ID: <57C44C38.4010203@cumulusnetworks.com>
References: <1472226767-9904-1-git-send-email-david.lebrun@uclouvain.be> <1472226767-9904-5-git-send-email-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Lebrun <david.lebrun@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:33291 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757417AbcH2Ow5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 10:52:57 -0400
Received: by mail-pf0-f182.google.com with SMTP id y134so52815385pfg.0
        for <netdev@vger.kernel.org>; Mon, 29 Aug 2016 07:52:57 -0700 (PDT)
In-Reply-To: <1472226767-9904-5-git-send-email-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/26/16, 8:52 AM, David Lebrun wrote:
> This patch creates a new type of interfaceless lightweight tunnel (SEG6),
> enabling the encapsulation and injection of SRH within locally emitted
> packets and forwarded packets.
>
> From a configuration viewpoint, a seg6 tunnel would be configured as follows:
>
>   ip -6 ro ad fc00::1/128 via <gw> encap seg6 mode encap segs fc42::1,fc42::2,fc42::3
>
> Any packet whose destination address is fc00::1 would thus be encapsulated
> within an outer IPv6 header containing the SRH with three segments, and would
> actually be routed to the first segment of the list. If `mode inline' was
> specified instead of `mode encap', then the SRH would be directly inserted
> after the IPv6 header without outer encapsulation.
>
> Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
> ---

You will need to account for lwtunnel headroom ?
https://patchwork.ozlabs.org/patch/662632/

thanks,
Roopa
