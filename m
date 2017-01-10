From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH 1/3] Revert "icmp: avoid allocating large
 struct on stack"
Date: Tue, 10 Jan 2017 21:08:20 +0100
Message-ID: <20170110210820.1c5dbc87@redhat.com>
References: <1483985224.21472.3.camel@edumazet-glaptop3.roam.corp.google.com>
        <20170109.135259.988711786570465428.davem@davemloft.net>
        <CAM_iQpUbcVogq7jGePkgPJ0z_J=46hnK8KcTiX1svVXr1Hoh-w@mail.gmail.com>
        <20170110.131223.748150430551443881.davem@davemloft.net>
        <CAM_iQpV0V23fndi6DOW1gu9kq+2UufHNrnfRYCME7uOOLCaX-Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        brouer@redhat.com
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55466 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S964918AbdAJUI1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 10 Jan 2017 15:08:27 -0500
In-Reply-To: <CAM_iQpV0V23fndi6DOW1gu9kq+2UufHNrnfRYCME7uOOLCaX-Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 10 Jan 2017 10:44:59 -0800 Cong Wang <xiyou.wangcong@gmail.com> wrote:

> On Tue, Jan 10, 2017 at 10:12 AM, David Miller <davem@davemloft.net> wrote:
[...]
> > You can keep showing us how expertly you can deflect the real
> > issue we are discussion here, but that won't improve the situation
> > at all I am afraid.  
> 
> Of course, there are just too many people too lazy to do a google search:
> 
> https://lists.debian.org/debian-kernel/2013/05/msg00500.html

My analysis of the problem shown in above link is not related to using
all the stack space, but instead that skb->cb was not cleared.  This
can cause the ip_options_echo() call in icmp_send() to access garbage
as this is: __ip_options_echo(dopt, skb, &IPCB(skb)->opt).

Fixed by commit a622260254ee ("ip_tunnel: fix kernel panic with icmp_dest_unreach")
 https://git.kernel.org/torvalds/c/a622260254ee

Thus, it is (likely) the __ip_options_echo() call that violates stack
access, as it is passed in a pointer to the stack, and advance this
based on garbage "optlen".

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
