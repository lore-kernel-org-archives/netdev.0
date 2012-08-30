From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1] tcp: Wrong timeout for SYN segments
Date: Thu, 30 Aug 2012 06:12:30 -0700
Message-ID: <1346332350.2586.10.camel@edumazet-glaptop>
References: <1345724123.5904.756.camel@edumazet-glaptop>
	 <50362407.9070805@linlab.net> <1345726185.5904.835.camel@edumazet-glaptop>
	 <20120824.134231.41073001349178209.davem@davemloft.net>
	 <20120825084819.GD430@linlab.net>
	 <CAFbMe2Pgjbttt+Z3RQ9KL05=GHqZYk5ubNH2G1-EUn_f_RBaEQ@mail.gmail.com>
	 <1346230305.2522.15.camel@edumazet-glaptop>
	 <CAFbMe2PG90X7s6s970+XK3X0Jvzx4p6vhvM+JQCwtULPvs1QLw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Bergmann <alex@linlab.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "H.K. Jerry Chu" <hkjerry.chu@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAFbMe2PG90X7s6s970+XK3X0Jvzx4p6vhvM+JQCwtULPvs1QLw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-08-29 at 10:25 -0700, H.K. Jerry Chu wrote:

> But it probably matter slightly more for TCP Fast Open (the server
> side patch has
> been completed and will be posted soon, after I finish breaking it up
> into smaller
> pieces for ease of review purpose), when a full socket will be created with data
> passed to the app upon a valid SYN+data. Dropping a fully functioning socket
> won't be the same as dropping a request_sock unknown to the app and letting
> the other side retransmitting SYN (w/o data this time).
> 
> >
> > Sure, RFC numbers are what they are, but in practice, I doubt someone
> > will really miss the extra SYNACK sent after ~32 seconds, since it would
> > matter only for the last SYN attempted.
> 
> I'd slightly prefer 1 extra retry plus longer wait time just to make
> TCP Fast Open
> a little more robust (even though the app protocol is required to be
> idempotent).
> But this is not a showstopper.

Thats very good points indeed, thanks.

Maybe we can increase SYNACK max retrans only if the FastOpen SYN cookie
was validated.

This way, we increase reliability without amplifying the effect of wild
SYN packets.
