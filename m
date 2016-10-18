From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net] bridge: multicast: restore perm router ports on
 multicast enable
Date: Tue, 18 Oct 2016 16:16:45 +0200
Message-ID: <0cdace0f-ac89-6ac5-c8ab-40b8490bed62@cumulusnetworks.com>
References: <1476796238-9384-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, roopa@cumulusnetworks.com,
        stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f46.google.com ([209.85.215.46]:32815 "EHLO
        mail-lf0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759876AbcJROQt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2016 10:16:49 -0400
Received: by mail-lf0-f46.google.com with SMTP id x79so358599346lff.0
        for <netdev@vger.kernel.org>; Tue, 18 Oct 2016 07:16:48 -0700 (PDT)
In-Reply-To: <1476796238-9384-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18/10/16 15:10, Nikolay Aleksandrov wrote:
> Satish reported a problem with the perm multicast router ports not getting
> reenabled after some series of events, in particular if it happens that the
> multicast snooping has been disabled and the port goes to disabled state
> then it will be deleted from the router port list, but if it moves into
> non-disabled state it will not be re-added because the mcast snooping is
> still disabled, and enabling snooping later does nothing.
> 
> Here are the steps to reproduce, setup br0 with snooping enabled and eth1
> added as a perm router (multicast_router = 2):
> 1. $ echo 0 > /sys/class/net/br0/bridge/multicast_snooping
> 2. $ ip l set eth1 down
> ^ This step deletes the interface from the router list
> 3. $ ip l set eth1 up
> ^ This step does not add it again because mcast snooping is disabled
> 4. $ echo 1 > /sys/class/net/br0/bridge/multicast_snooping
> 5. $ bridge -d -s mdb show
> <empty>
> 
> At this point we have mcast enabled and eth1 as a perm router (value = 2)
> but it is not in the router list which is incorrect.
> 
> After this change:
> 1. $ echo 0 > /sys/class/net/br0/bridge/multicast_snooping
> 2. $ ip l set eth1 down
> ^ This step deletes the interface from the router list
> 3. $ ip l set eth1 up
> ^ This step does not add it again because mcast snooping is disabled
> 4. $ echo 1 > /sys/class/net/br0/bridge/multicast_snooping
> 5. $ bridge -d -s mdb show
> router ports on br0: eth1
> 
> Fixes: 561f1103a2b7 ("bridge: Add multicast_snooping sysfs toggle")
> Reported-by: Satish Ashok <sashok@cumulusnetworks.com>
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> ---
>  net/bridge/br_multicast.c | 18 +++++++++++++++++-
>  1 file changed, 17 insertions(+), 1 deletion(-)
> 

Self-NAK. I sent an older version of the patch, v2 coming up.
Sorry for the noise.
