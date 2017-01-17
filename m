From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net] lwtunnel: fix autoload of lwt modules
Date: Tue, 17 Jan 2017 10:07:15 -0700
Message-ID: <8b621810-f7b3-05bb-413b-29389125c6ea@cumulusnetworks.com>
References: <1484631185-9428-1-git-send-email-dsa@cumulusnetworks.com>
 <e6637ef9-02e4-bbfc-b5f0-bdd7c560714e@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Robert Shearman <rshearma@brocade.com>, netdev@vger.kernel.org,
        roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:35862 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750992AbdAQRIA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 12:08:00 -0500
Received: by mail-pf0-f181.google.com with SMTP id 189so63471460pfu.3
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 09:07:20 -0800 (PST)
In-Reply-To: <e6637ef9-02e4-bbfc-b5f0-bdd7c560714e@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/17/17 3:04 AM, Robert Shearman wrote:
> Is it safe to release the rtnl lock here? E.g. neither fib_get_nhs nor fib_create_info take a reference on the device and further up inet_rtm_newroute has a pointer to the struct fib_table without taking a reference.

fib tables can not be deleted so that reference is safe. You are right about the dev reference in the IPv4 path but the thing is build_state does not need the device reference.

Roopa: do you recall why dev is passed to build_state? Nothing about the encap should require a device reference and none of the current encaps use it.

> 
> Unfortunately, I think more invasive changes are required to solve this. I'm happy to work on solving this.

I have a patch that removes passing dev to build_state. Walking the remainder of the code I do not see any more references that would be affected by dropping rtnl here on the add path. Still looking at the delete path.
