From: Cheng Jin <chengjin@cs.caltech.edu>
Subject: Re: TCP receiver's window calculation problem
Date: Thu, 24 Jun 2004 23:37:35 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0406241331590.1272-100000@orchestra.cs.caltech.edu>
References: <Pine.NEB.4.33.0406241519430.28506-100000@dexter.psc.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "netdev@oss.sgi.com" <netdev@oss.sgi.com>,
        "fast-support@cs.caltech.edu" <fast-support@cs.caltech.edu>
Return-path: <netdev-bounce@oss.sgi.com>
To: John Heffner <jheffner@psc.edu>
In-Reply-To: <Pine.NEB.4.33.0406241519430.28506-100000@dexter.psc.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


John,

> > I think having a default limit on tcp memory is acceptable to prevent DoS,
> > but when a user increases the memory limit by explicitly setting tcp_rmem,
> > that should take effect.  The code itself shouldnt pose any limit like it
> > does now.
> 
> The core of the problem is that you are describing a truesize of each skb
> at about 16k, but each of those only contains < 1500 bytes of payload.
> You are wasting 90% of your socket memory.  Announcing a 3 MB window with
> a 30 MB socket buffer is the right thing to do, from a certain point of
> view.  OTOH, it kills performance.

The receiver is set to use a 9000 MTU, but the sender uses a 1500-byte 
MTU, which is not really a pathological case.  It would have made more
sense for the receiver to allocate skbs of the right size as incoming 
packets are received.  

Is it due to effciency reasons that the skbs are just fixed in size 
according to the set MTU on the interface card? I suppose that the 
receiver has no real way of knowing the right MTU size at the sender.

Thanks,

Cheng
