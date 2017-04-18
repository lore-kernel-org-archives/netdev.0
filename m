From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net-next] net: ipv6: Add early demux handler for UDP
 unicast
Date: Tue, 18 Apr 2017 17:09:04 +0900
Message-ID: <20170418080902.GA25804@vergenet.net>
References: <1488997457-24554-1-git-send-email-subashab@codeaurora.org>
 <1488998446.28631.13.camel@edumazet-glaptop3.roam.corp.google.com>
 <8b6968063320eb8ddc654f79d3461f21@codeaurora.org>
 <1489000921.28631.18.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>,
        netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:33745 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754700AbdDRIJK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 04:09:10 -0400
Received: by mail-pg0-f46.google.com with SMTP id 63so24146116pgh.0
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 01:09:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1489000921.28631.18.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 08, 2017 at 11:22:01AM -0800, Eric Dumazet wrote:
> On Wed, 2017-03-08 at 12:11 -0700, Subash Abhinov Kasiviswanathan wrote:
> > On 2017-03-08 11:40, Eric Dumazet wrote:
> > > Well, this 'optimization' actually hurts when UDP sockets are not
> > > connected, since this adds an extra cache line miss per incoming 
> > > packet.
> > > 
> > > (DNS servers for example)
> > 
> > Hi Eric
> > 
> > Thanks for your comments. Would it be preferable to disable early demux 
> > for the
> > servers with large unconnected workloads in that case?
> 
> Well, many servers handle both TCP and UDP.
> 
> For TCP, there is no question about early demux, this is definitely a
> win.
> 
> We probably should have one sysctl to enable TCP early demux, one for
> UDP early demux.

If early demux is a clear win for TCP then I wonder if it is
unnecessary and by some leap also undesirable to have a configuration
knob for that case.
