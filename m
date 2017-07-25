From: Trevor Cordes <trevor@tecnopolis.ca>
Subject: Re: c21b48 causes nfs client to hang and kernel BUG at
 ./include/linux/mm.h:432 (bisected)
Date: Tue, 25 Jul 2017 02:02:26 -0500
Message-ID: <20170725020226.6a824cbc@pog.tecnopolis.ca>
References: <20170723123504.GA4312@pog.tecnopolis.ca>
        <CANn89iLQ6CiTCSQcvoPRvodzt4cSBkSfH+YGJuspoL0=vZG8kg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Andrey Konovalov <andreyknvl@google.com>,
        Willem de Bruijn <willemb@google.com>,
        netdev <netdev@vger.kernel.org>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ewordofmouth.com ([72.3.247.85]:52224 "EHLO ewordofmouth.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750746AbdGYHYe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 25 Jul 2017 03:24:34 -0400
In-Reply-To: <CANn89iLQ6CiTCSQcvoPRvodzt4cSBkSfH+YGJuspoL0=vZG8kg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017-07-24 Eric Dumazet wrote:
> On Sun, Jul 23, 2017 at 5:35 AM, Trevor Cordes <trevor@tecnopolis.ca>
> wrote:
> > Hi!  I've bisected a bug I'm seeing to:
> > c21b48cc1bbf2f5af3ef54ada559f7fadf8b508b
> > net: adjust skb->truesize in ___pskb_trim()
> >
> > The bug manifests as my NFS4 (TCP) client mount hanging after 5-10s
> > of heavy read data transfer, which also produces: kernel BUG at
> > ./include/linux/mm.h:462 (see full trace at bottom)
> 
> Hi Trevor, thanks for the report and bisection !
> 
> This commit exposed at least one bug, have you tried the following
> fix :
> 
> e44699d2c28067f69698ccb68dd3ddeacfebc434 ("net: handle
> NAPI_GRO_FREE_STOLEN_HEAD case also in napi_frags_finish()")
> 
> If this commit does not help, please provide what kind of NIC you are
> using.

Hi!  e44699d2c28067f69698ccb68dd3ddeacfebc434 I just compiled into
stock fedora 24 4.11.10 (and removed my kludge c21b48 back-out patch).
Indeed it does solve my bug!

Is there a way to find out what version of the kernel that e44699 will
show up in so I can watch for it in stock Fedora?  i.e. 4.11.55 or
4.12.55?

I'll update the rhbz so maybe Fedora can get rebased or include e44699
as a patch.

My NIC is Intel 82545GM

Thanks!!  (Hmmm... I wonder if e44699 also solves the smb client
hanging I've been seeing since last year...)
