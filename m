From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net] net: Avoid receiving packets with an l3mdev on
 unbound UDP sockets
Date: Thu, 26 Jan 2017 11:12:50 -0700
Message-ID: <52c73e8e-56e8-efe4-49df-e189f35e3017@cumulusnetworks.com>
References: <1485453744-5120-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Robert Shearman <rshearma@brocade.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:36189 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753616AbdAZSNU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 13:13:20 -0500
Received: by mail-pf0-f178.google.com with SMTP id 189so67029753pfu.3
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 10:12:52 -0800 (PST)
In-Reply-To: <1485453744-5120-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/26/17 11:02 AM, Robert Shearman wrote:
> Packets arriving in a VRF currently are delivered to UDP sockets that
> aren't bound to any interface. TCP defaults to not delivering packets
> arriving in a VRF to unbound sockets. IP route lookup and socket
> transmit both assume that unbound means using the default table and
> UDP applications that haven't been changed to be aware of VRFs may not
> function correctly in this case since they may not be able to handle
> overlapping IP address ranges, or be able to send packets back to the
> original sender if required.
> 
> So add a sysctl, udp_l3mdev_accept, to control this behaviour with it
> being analgous to the existing tcp_l3mdev_accept, namely to allow a
> process to have a VRF-global listen socket. Have this default to off
> as this is the behaviour that users will expect, given that there is
> no explicit mechanism to set unmodified VRF-unaware application into a
> default VRF.
> 
> Signed-off-by: Robert Shearman <rshearma@brocade.com>
> ---
> I've targetted this for the net tree because I believe the expected
> behaviour is different enough from the current behaviour to be
> considered a bug. However, this should also apply to the net-next tree
> as-is if this not deemed a bug.
> 

I have almost this exact patch in my tree and I have it marked as not working so 1 or more test cases is failing.

So, really this is just a note that I need to test this and need some time to get to it.
