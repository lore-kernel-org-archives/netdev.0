From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] allow setting mtu and txqlen via RTM_SETLINK and provide txqlen via RTM_GETLINK
Date: Tue, 24 Aug 2004 11:49:52 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040824094952.GF21073@postel.suug.ch>
References: <20040823205114.GB19921@postel.suug.ch> <E1BzR1C-0000c4-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, kuznet@ms2.inr.ac.ru, hadi@cyberus.ca,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1BzR1C-0000c4-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Herbert Xu <E1BzR1C-0000c4-00@gondolin.me.apana.org.au> 2004-08-24 12:26
> Thomas Graf <tgraf@suug.ch> wrote:
> >
> > +       RTA_PUT(skb, IFLA_TXQLEN, sizeof(unsigned long), &dev->tx_queue_len);
> 
> Please use a fixed width type like u32.

I used the same type as it is stored in struct net_device to avoid data
loss on certain architectures. Due to the fact that the size of the
attribute is provided to the userspace receiver, no guessing is involved.
Using u32 would mean to do an unnecessary cast.

> Keep in mind that the ioctl version is exporting an int.

Yes, but the size of ivalue is also dependent on the architecture and
the cast to int is done for compatibility reasons.

   Thomas
