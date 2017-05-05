From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net] tcp: randomize timestamps on syncookies
Date: Fri, 05 May 2017 06:46:23 -0700
Message-ID: <1493991983.7796.40.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1493935361.7796.29.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170505002456.GH13320@breakpoint.cc>
         <20170505003208.GI13320@breakpoint.cc>
         <1493949548.7796.32.camel@edumazet-glaptop3.roam.corp.google.com>
         <1493950957.7796.36.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170505093630.GA3233@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Yuchung Cheng <ycheng@google.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:35928 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752207AbdEENql (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 5 May 2017 09:46:41 -0400
Received: by mail-pf0-f170.google.com with SMTP id q66so3030947pfi.3
        for <netdev@vger.kernel.org>; Fri, 05 May 2017 06:46:39 -0700 (PDT)
In-Reply-To: <20170505093630.GA3233@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-05-05 at 11:36 +0200, Florian Westphal wrote:
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > Whole point of randomization was to hide server uptime, but an attacker
> > can simply start a syn flood and TCP generates 'old style' timestamps,
> > directly revealing server jiffies value.
> > 
> > Also, TSval sent by the server to a particular remote address vary
> > depending on syncookies being sent or not, potentially triggering PAWS
> > drops for innocent clients.
> > 
> > Lets implement proper randomization, including for SYNcookies.
> 
> 
> Thanks a lot Eric, this works for me (I also tested ipv6 this time ;) )
> 
> Minor nit:
> net/ipv4/tcp_ipv4.c:154:6: warning: unused variable 'seq' [-Wunused-variable]
> 

Thanks Florian, I will remove this in v3, and add your tags.

> Other than this:
> Reviewed-by: Florian Westphal <fw@strlen.de>
> Tested-by: Florian Westphal <fw@strlen.de>
