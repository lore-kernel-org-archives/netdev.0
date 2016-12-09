From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next 0/4] udp: receive path optimizations
Date: Fri, 09 Dec 2016 08:53:11 -0800
Message-ID: <1481302391.4930.201.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1481218739-27089-1-git-send-email-edumazet@google.com>
         <20161208214819.30138d12@redhat.com>
         <1481231595.4930.142.camel@edumazet-glaptop3.roam.corp.google.com>
         <20161209170509.25347c9b@redhat.com>
         <1481300787.4930.198.camel@edumazet-glaptop3.roam.corp.google.com>
         <CALx6S35roMkor_0maXk-SwdXeF4GxBfbxXLEXLGnn6mRRaut6g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
        Eric Dumazet <edumazet@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>, Paolo Abeni <pabeni@redhat.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34999 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933046AbcLIQyN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Dec 2016 11:54:13 -0500
Received: by mail-pg0-f66.google.com with SMTP id p66so2807457pga.2
        for <netdev@vger.kernel.org>; Fri, 09 Dec 2016 08:54:13 -0800 (PST)
In-Reply-To: <CALx6S35roMkor_0maXk-SwdXeF4GxBfbxXLEXLGnn6mRRaut6g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-12-09 at 08:43 -0800, Tom Herbert wrote:
> 
> 


> Are you thinking of allowing unconnected socket to have multiple input
> queues? Sort of an automatic and transparent SO_REUSEPORT... 

It all depends if the user application is using a single thread or
multiple threads to drain the queue.

Since we used to grab socket lock in udp_recvmsg(), I guess nobody uses
multiple threads to read packets from a single socket.

So heavy users must use SO_REUSEPORT already, not sure what we would
gain trying to go to a single socket, with the complexity of mem
charging.


> 
