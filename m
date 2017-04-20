From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net] ipv4: Avoid caching dsts when lookup skipped nh oif
 check
Date: Thu, 20 Apr 2017 08:21:15 -0600
Message-ID: <bed3d38c-dc00-1f98-371c-852170af0a0e@cumulusnetworks.com>
References: <1492693132-4708-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Robert Shearman <rshearma@brocade.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f178.google.com ([209.85.213.178]:36144 "EHLO
        mail-yb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S946368AbdDTOVV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 10:21:21 -0400
Received: by mail-yb0-f178.google.com with SMTP id s22so28059564ybe.3
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 07:21:20 -0700 (PDT)
In-Reply-To: <1492693132-4708-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/20/17 6:58 AM, Robert Shearman wrote:
> David reported that doing the following:
> 
>     ip li add red type vrf table 10
>     ip link set dev eth1 vrf red
>     ip addr add 127.0.0.1/8 dev red
>     ip link set dev eth1 up
>     ip li set red up
>     ping -c1 -w1 -I red 127.0.0.1
>     ip li del red
> 
> results in a hang with this message:
> 
>     unregister_netdevice: waiting for red to become free. Usage count = 1

I think you misunderstood my comment. The above works fine today. There
is no bug with refcnts.

It breaks with your patches wanting to use a VRF device with the main
table (254).
