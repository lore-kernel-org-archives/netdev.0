From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net v3] net: ipmr: Fix some mroute forwarding issues in
 vrf's
Date: Sun, 11 Jun 2017 03:21:50 +0300
Message-ID: <142edc1e-4d8b-ae6f-05eb-7b4504e744e0@cumulusnetworks.com>
References: <20170610203017.4085-1-sharpd@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Donald Sharp <sharpd@cumulusnetworks.com>, netdev@vger.kernel.org,
        dsahern@gmail.com, Thomas.Winter@alliedtelesis.co.nz,
        yotamg@mellanox.com, idosch@mellanox.com, roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f170.google.com ([209.85.128.170]:35583 "EHLO
        mail-wr0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751768AbdFKAVy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Jun 2017 20:21:54 -0400
Received: by mail-wr0-f170.google.com with SMTP id q97so63900983wrb.2
        for <netdev@vger.kernel.org>; Sat, 10 Jun 2017 17:21:53 -0700 (PDT)
In-Reply-To: <20170610203017.4085-1-sharpd@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/06/17 23:30, Donald Sharp wrote:
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

Looks good, thanks!

Acked-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
