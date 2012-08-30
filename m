From: "H.K. Jerry Chu" <hkjerry.chu@gmail.com>
Subject: Re: [PATCH 1/1] tcp: Wrong timeout for SYN segments
Date: Thu, 30 Aug 2012 10:59:39 -0700
Message-ID: <CAFbMe2OtGmon9iWdC89T3RkWp526XCbNo-3SFAZ+nBmQRgT0Vg@mail.gmail.com>
References: <1345724123.5904.756.camel@edumazet-glaptop>
	<50362407.9070805@linlab.net>
	<1345726185.5904.835.camel@edumazet-glaptop>
	<20120824.134231.41073001349178209.davem@davemloft.net>
	<20120825084819.GD430@linlab.net>
	<CAFbMe2Pgjbttt+Z3RQ9KL05=GHqZYk5ubNH2G1-EUn_f_RBaEQ@mail.gmail.com>
	<1346230305.2522.15.camel@edumazet-glaptop>
	<CAFbMe2PG90X7s6s970+XK3X0Jvzx4p6vhvM+JQCwtULPvs1QLw@mail.gmail.com>
	<1346332350.2586.10.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Alexander Bergmann <alex@linlab.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1346332350.2586.10.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 30, 2012 at 6:12 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2012-08-29 at 10:25 -0700, H.K. Jerry Chu wrote:
>
>> But it probably matter slightly more for TCP Fast Open (the server
>> side patch has
>> been completed and will be posted soon, after I finish breaking it up
>> into smaller
>> pieces for ease of review purpose), when a full socket will be created with data
>> passed to the app upon a valid SYN+data. Dropping a fully functioning socket
>> won't be the same as dropping a request_sock unknown to the app and letting
>> the other side retransmitting SYN (w/o data this time).
>>
>> >
>> > Sure, RFC numbers are what they are, but in practice, I doubt someone
>> > will really miss the extra SYNACK sent after ~32 seconds, since it would
>> > matter only for the last SYN attempted.
>>
>> I'd slightly prefer 1 extra retry plus longer wait time just to make
>> TCP Fast Open
>> a little more robust (even though the app protocol is required to be
>> idempotent).
>> But this is not a showstopper.
>
> Thats very good points indeed, thanks.
>
> Maybe we can increase SYNACK max retrans only if the FastOpen SYN cookie
> was validated.
>
> This way, we increase reliability without amplifying the effect of wild
> SYN packets.

Ok, will use sysctl_tcp_synack_retries + 1 in tcp_fastopen_synack_timer() of my
upcoming TCP Fast Open server patch (hope to submit today).

Jerry

>
>
>
