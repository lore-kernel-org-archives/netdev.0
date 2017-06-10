From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net v3] net: ipmr: Fix some mroute forwarding issues in
 vrf's
Date: Sat, 10 Jun 2017 17:33:59 -0600
Message-ID: <a7d1c403-408c-d8ec-d552-ee417be68b50@gmail.com>
References: <20170610203017.4085-1-sharpd@cumulusnetworks.com>
 <20170610.190759.166589591911771854.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Thomas.Winter@alliedtelesis.co.nz,
        nikolay@cumulusnetworks.com, yotamg@mellanox.com,
        idosch@mellanox.com, roopa@cumulusnetworks.com
To: David Miller <davem@davemloft.net>, sharpd@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33294 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751647AbdFJXeB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Jun 2017 19:34:01 -0400
Received: by mail-pf0-f194.google.com with SMTP id w12so2432547pfk.0
        for <netdev@vger.kernel.org>; Sat, 10 Jun 2017 16:34:01 -0700 (PDT)
In-Reply-To: <20170610.190759.166589591911771854.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/10/17 5:07 PM, David Miller wrote:
> From: Donald Sharp <sharpd@cumulusnetworks.com>
> Date: Sat, 10 Jun 2017 16:30:17 -0400
> 
>> This patch fixes two issues:
>>
>> 1) When forwarding on *,G mroutes that are in a vrf, the
>> kernel was dropping information about the actual incoming
>> interface when calling ip_mr_forward from ip_mr_input.
>> This caused ip_mr_forward to send the multicast packet
>> back out the incoming interface.  Fix this by
>> modifying ip_mr_forward to be handed the correctly
>> resolved dev.
>>
>> 2) When a unresolved cache entry is created we store
>> the incoming skb on the unresolved cache entry and
>> upon mroute resolution from the user space daemon,
>> we attempt to forward the packet.  Again we were
>> not resolving to the correct incoming device for
>> a vrf scenario, before calling ip_mr_forward.
>> Fix this by resolving to the correct interface
>> and calling ip_mr_forward with the result.
>>
>> Fixes: e58e41596811 ("net: Enable support for VRF with ipv4 multicast")
>> Signed-off-by: Donald Sharp <sharpd@cumulusnetworks.com>
> 
> David, please review.
> 

Responded. Would be good for the Mellanox team (and Thomas) to chime in
as well.
