From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: ipv6: Add early demux handler for UDP
 unicast
Date: Wed, 08 Mar 2017 11:22:01 -0800
Message-ID: <1489000921.28631.18.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1488997457-24554-1-git-send-email-subashab@codeaurora.org>
         <1488998446.28631.13.camel@edumazet-glaptop3.roam.corp.google.com>
         <8b6968063320eb8ddc654f79d3461f21@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35089 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753829AbdCHTbb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 14:31:31 -0500
Received: by mail-pg0-f67.google.com with SMTP id 187so4279784pgb.2
        for <netdev@vger.kernel.org>; Wed, 08 Mar 2017 11:31:06 -0800 (PST)
In-Reply-To: <8b6968063320eb8ddc654f79d3461f21@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-03-08 at 12:11 -0700, Subash Abhinov Kasiviswanathan wrote:
> On 2017-03-08 11:40, Eric Dumazet wrote:
> > Well, this 'optimization' actually hurts when UDP sockets are not
> > connected, since this adds an extra cache line miss per incoming 
> > packet.
> > 
> > (DNS servers for example)
> 
> Hi Eric
> 
> Thanks for your comments. Would it be preferable to disable early demux 
> for the
> servers with large unconnected workloads in that case?

Well, many servers handle both TCP and UDP.

For TCP, there is no question about early demux, this is definitely a
win.

We probably should have one sysctl to enable TCP early demux, one for
UDP early demux.
