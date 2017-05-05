From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH v2 net] tcp: randomize timestamps on syncookies
Date: Fri, 5 May 2017 11:36:30 +0200
Message-ID: <20170505093630.GA3233@breakpoint.cc>
References: <1493935361.7796.29.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170505002456.GH13320@breakpoint.cc>
 <20170505003208.GI13320@breakpoint.cc>
 <1493949548.7796.32.camel@edumazet-glaptop3.roam.corp.google.com>
 <1493950957.7796.36.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:60480 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751238AbdEEJgx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 5 May 2017 05:36:53 -0400
Content-Disposition: inline
In-Reply-To: <1493950957.7796.36.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> Whole point of randomization was to hide server uptime, but an attacker
> can simply start a syn flood and TCP generates 'old style' timestamps,
> directly revealing server jiffies value.
> 
> Also, TSval sent by the server to a particular remote address vary
> depending on syncookies being sent or not, potentially triggering PAWS
> drops for innocent clients.
> 
> Lets implement proper randomization, including for SYNcookies.


Thanks a lot Eric, this works for me (I also tested ipv6 this time ;) )

Minor nit:
net/ipv4/tcp_ipv4.c:154:6: warning: unused variable 'seq' [-Wunused-variable]

Other than this:
Reviewed-by: Florian Westphal <fw@strlen.de>
Tested-by: Florian Westphal <fw@strlen.de>
