From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH v2 net-next 00/14] mlx4: order-0 allocations and page
 recycling
Date: Sun, 12 Feb 2017 23:38:53 +0100
Message-ID: <20170212233853.193a2714@redhat.com>
References: <20170209135838.16487-1-edumazet@google.com>
        <3c48eac5-0c4f-f43a-1d76-75399e5fc1b8@gmail.com>
        <CANn89i+sbU7b5CAhRq15Mk021X4afkB5E1ip+FRB4NevOrYJvQ@mail.gmail.com>
        <c192d259-644b-0697-748f-549fdc9c11e0@gmail.com>
        <CANn89iLNvQyfXUZwtQuhXBgZrKCDWEaouVtD4Txaem_wDXrdQg@mail.gmail.com>
        <2a345874-2ad7-997e-2904-0d56148a2c56@gmail.com>
        <1486933066.8227.6.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Tariq Toukan <ttoukan.linux@gmail.com>,
        Eric Dumazet <edumazet@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Martin KaFai Lau <kafai@fb.com>,
        Willem de Bruijn <willemb@google.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <ast@kernel.org>, brouer@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57586 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750882AbdBLWi7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 12 Feb 2017 17:38:59 -0500
In-Reply-To: <1486933066.8227.6.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 12 Feb 2017 12:57:46 -0800
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Sun, 2017-02-12 at 18:31 +0200, Tariq Toukan wrote:
> > On 09/02/2017 6:56 PM, Eric Dumazet wrote:  
> > >> Default, out of box.  
> > > Well. Please report :
> > >
> > > ethtool  -l eth0
> > > ethtool -g eth0  
> > $ ethtool -g p1p1
> > Ring parameters for p1p1:
> > Pre-set maximums:
> > RX:             8192
> > RX Mini:        0
> > RX Jumbo:       0
> > TX:             8192
> > Current hardware settings:
> > RX:             1024
> > RX Mini:        0
> > RX Jumbo:       0
> > TX:             512  
> 
> We are using 4096 slots per RX queue, this is why I could not reproduce
> your results.

Just so others understand this: The number of RX queue slots is
indirectly the size of the page-recycle "cache" in this scheme (that
depend on refcnt tricks to see if page can be reused).  


> A single TCP flow easily can have more than 1024 MSS waiting in its
> receive queue (typical receive window on linux is 6MB/2 )

So, you do need to increase the page-"cache" size, and need this for
real-life cases, interesting.


> I mentioned that having a slightly inflated skb->truesize might have an
> impact in some workloads. (charging for 2048 bytes per MSS instead of
> 1536), but this is not related to mlx4 and should be tweaked in TCP
> stack instead, since this 2048 bytes (half a page on x86) strategy is
> now well spread.


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
