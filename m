From: John Heffner <jheffner@psc.edu>
Subject: Re: TCP receiver's window calculation problem
Date: Thu, 24 Jun 2004 15:26:27 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.NEB.4.33.0406241519430.28506-100000@dexter.psc.edu>
References: <Pine.LNX.4.44.0406241209280.1272-100000@orchestra.cs.caltech.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "netdev@oss.sgi.com" <netdev@oss.sgi.com>,
        "fast-support@cs.caltech.edu" <fast-support@cs.caltech.edu>
Return-path: <netdev-bounce@oss.sgi.com>
To: Cheng Jin <chengjin@cs.caltech.edu>
In-Reply-To: <Pine.LNX.4.44.0406241209280.1272-100000@orchestra.cs.caltech.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 24 Jun 2004, Cheng Jin wrote:

> I think having a default limit on tcp memory is acceptable to prevent DoS,
> but when a user increases the memory limit by explicitly setting tcp_rmem,
> that should take effect.  The code itself shouldnt pose any limit like it
> does now.

The core of the problem is that you are describing a truesize of each skb
at about 16k, but each of those only contains < 1500 bytes of payload.
You are wasting 90% of your socket memory.  Announcing a 3 MB window with
a 30 MB socket buffer is the right thing to do, from a certain point of
view.  OTOH, it kills performance.


> Actually, I am not clear what that window-calculation algorithm is.  Is it
> recommended by some RFC?

No, it's not standard.  I'm not sure who wrote this code.

  -John
