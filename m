From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH] net: VRF: Fix receiving multicast traffic
Date: Thu, 22 Sep 2016 09:14:49 -0600
Message-ID: <aac5b560-d757-3281-8e69-7953e7c4b418@cumulusnetworks.com>
References: <20160922041308.30848-1-mark.tomlinson@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Mark Tomlinson <mark.tomlinson@alliedtelesis.co.nz>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:34626 "EHLO
        mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933216AbcIVPOt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 11:14:49 -0400
Received: by mail-pa0-f46.google.com with SMTP id wk8so30211797pab.1
        for <netdev@vger.kernel.org>; Thu, 22 Sep 2016 08:14:49 -0700 (PDT)
In-Reply-To: <20160922041308.30848-1-mark.tomlinson@alliedtelesis.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/21/16 10:13 PM, Mark Tomlinson wrote:
> The previous patch to ensure that the original iif was used when
> checking for forwarding also meant that this same interface was used to
> determine whether multicast packets should be received or not. This was
> incorrect, and would cause multicast packets to be dropped.
> 
> The fix here is to use skb->dev when checking multicast addresses.
> skb->dev has been set to the l3mdev by this point, so the check will be
> against that, rather than the ingress interface.

l3mdev devices do not support IPv4 multicast so checking mcast against that device should not be working at all. For that reason I was fine with the change in the previous patch. ie., you want the real ingress device there not the vrf device.

What test are you running that says your previous patch broke something?
