From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: v4.14-rc2/arm64 kernel BUG at net/core/skbuff.c:2626
Date: Mon, 2 Oct 2017 16:01:57 +0100
Message-ID: <20171002150156.GC21696@leverpostej>
References: <20171002104947.GE20737@leverpostej>
 <CANn89i++X2rzsaHkTRayMpCED_exL8WPq12=RwD_hXsZ6cN-wQ@mail.gmail.com>
 <20171002142156.GB21696@leverpostej>
 <CANn89i+zQG=rjHRqzsvPzjg5tqW43Lcz-BJ9spLascP9Nt5z8Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>,
        linux-arm-kernel@lists.infradead.org,
        syzkaller <syzkaller@googlegroups.com>,
        "David S. Miller" <davem@davemloft.net>,
        Willem de Bruijn <willemb@google.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CANn89i+zQG=rjHRqzsvPzjg5tqW43Lcz-BJ9spLascP9Nt5z8Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 02, 2017 at 07:42:17AM -0700, Eric Dumazet wrote:
> On Mon, Oct 2, 2017 at 7:21 AM, Mark Rutland <mark.rutland@arm.com> wrote:
> > Just to check I've understood correctly, are you suggesting that the
> > IPv4 code should also check the dev->mtu against a IP_MIN_MTU (which
> > doesn't seem to exist today)?
> 
> We have plenty of places this is checked.
> 
> For example, trying to set MTU < 68 usually removes IPv4 addresses and routes.
> 
> Problem is : these checks are not fool proof yet.
> 
> ( Only the admin was supposed to play these games )

Sorry, I meant that there was no constant called IP_MIN_MTU, and I was
just looking at the sites fixed up by c780a049f9bf4423.

I appreciate given that this requires admin privileges it's not exactly
high priority. I didn't mean for the above to sound like some kind of
accusation!

> > Otherwise, I do spot another potential issue. The writer side (e.g. most
> > net_device::ndo_change_mtu implementations and the __dev_set_mtu()
> > fallback) doesn't use WRITE_ONCE().
> 
> It does not matter how many strange values can be observed by the reader :
> We must be fool proof anyway from reader point of view, so the
> WRITE_ONCE() is not strictly needed.

Ok. If we expect to always check somewhere on the reader side I guess
that makes sense.

Thanks,
Mark.
