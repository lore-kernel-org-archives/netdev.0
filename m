From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH v4] net: ip, diag -- Add diag interface for raw sockets
Date: Tue, 27 Sep 2016 18:45:40 +0300
Message-ID: <20160927154540.GO1876@uranus.lan>
References: <20160927150831.GN1876@uranus.lan>
 <1474990799.28155.54.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, avagin@openvz.org, stephen@networkplumber.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1474990799.28155.54.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 27, 2016 at 08:39:59AM -0700, Eric Dumazet wrote:
...
> > +	}
> > +	if (sk && !atomic_inc_not_zero(&sk->sk_refcnt))
> > +		sk = NULL;
> 
> Minor detail, but note that raw sockets do not use rcu (yet)
> 
> Since you have read_lock(&hashinfo->lock), no writer can suddenly change
> sk->sk_refcnt to a zero value.
> 
> Therefore, a mere "sock_hold(sk)" should be enough to get a reference on
> the socket.
> 
> Using atomic_inc_not_zero() also works, but might distract/confuse the
> next guy trying to understand this code ;)

Oh, I see. Thanks Eric! I'll update the patch (hopefully tonight)
and send it out (need to finish urgent task atm).
