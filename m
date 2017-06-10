From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net v3] net: ipmr: Fix some mroute forwarding issues in
 vrf's
Date: Sat, 10 Jun 2017 17:32:33 -0600
Message-ID: <25a39bcd-d623-951a-75c5-773b2cc0518e@gmail.com>
References: <20170610203017.4085-1-sharpd@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Donald Sharp <sharpd@cumulusnetworks.com>, netdev@vger.kernel.org,
        Thomas.Winter@alliedtelesis.co.nz, nikolay@cumulusnetworks.com,
        yotamg@mellanox.com, idosch@mellanox.com, roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35792 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751558AbdFJXcf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Jun 2017 19:32:35 -0400
Received: by mail-pg0-f67.google.com with SMTP id f127so10974196pgc.2
        for <netdev@vger.kernel.org>; Sat, 10 Jun 2017 16:32:35 -0700 (PDT)
In-Reply-To: <20170610203017.4085-1-sharpd@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/10/17 2:30 PM, Donald Sharp wrote:
> This patch fixes two issues:
> 
> 1) When forwarding on *,G mroutes that are in a vrf, the
> kernel was dropping information about the actual incoming
> interface when calling ip_mr_forward from ip_mr_input.
> This caused ip_mr_forward to send the multicast packet
> back out the incoming interface.  Fix this by
> modifying ip_mr_forward to be handed the correctly
> resolved dev.
> 
> 2) When a unresolved cache entry is created we store
> the incoming skb on the unresolved cache entry and
> upon mroute resolution from the user space daemon,
> we attempt to forward the packet.  Again we were
> not resolving to the correct incoming device for
> a vrf scenario, before calling ip_mr_forward.
> Fix this by resolving to the correct interface
> and calling ip_mr_forward with the result.
> 
> Fixes: e58e41596811 ("net: Enable support for VRF with ipv4 multicast")
> Signed-off-by: Donald Sharp <sharpd@cumulusnetworks.com>
> ---
> v2: Fixed title
> v3: Addressed Review comments by Andrew Lunn and David Ahern
> 

LGTM.

Acked-by: David Ahern <dsahern@gmail.com>
