From: "John Heffner" <johnwheffner@gmail.com>
Subject: Re: Why is tcp_reno_min_cwnd() ssthresh/2?
Date: Fri, 4 Apr 2008 09:24:47 -0700
Message-ID: <1e41a3230804040924q34d009c9w97dded92f13392dc@mail.gmail.com>
References: <aa7d2c6d0804031800r7d796b40oc011e684bcd2f0c0@mail.gmail.com>
	 <7335583a0804031935g49a843dbq8b8c132411501a8b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Lachlan Andrew" <lachlan.andrew@gmail.com>,
	Netdev <netdev@vger.kernel.org>
To: "Xiaoliang David Wei" <davidwei79@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rn-out-0910.google.com ([64.233.170.189]:47944 "EHLO
	rn-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752483AbYDDQYu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2008 12:24:50 -0400
Received: by rn-out-0910.google.com with SMTP id e24so212607rng.1
        for <netdev@vger.kernel.org>; Fri, 04 Apr 2008 09:24:48 -0700 (PDT)
In-Reply-To: <7335583a0804031935g49a843dbq8b8c132411501a8b@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

That's my understanding as well.  I'm pretty sure this has come up on
the list before, more than once.  Someone should probably add a
comment there.

Also, I'm pretty sure no one has a strong opinion that this bound must
be cwnd/4.  In fact it is known to behave poorly in some situations.
An argument for a different value or approach may be well received.

  -John


On Thu, Apr 3, 2008 at 7:35 PM, Xiaoliang David Wei
<davidwei79@gmail.com> wrote:
> Hi Lachlan,
>
>     I think the reno_min_cwnd gives a lower bound of the cwnd during
>  one round of rate halving. So it is not *always* that cwnd will go to
>  reno_min_cwnd. If the recovery is done before the cwnd dropping to
>  reno_min_cwnd, the cwnd will be drop by at least one half. I think the
>  assumption is that normally one round of rate-halving will end up with
>  a half of congestion window so this lower bound is not activated.
>
>     The last time I examined this algorithm, I got the following
>  document about rate halving:
>  http://www.psc.edu/networking/papers/FACKnotes/current/
>
>     (It might be possible that the assumptions in this draft might be
>  out-dated or I misunderstood the algorithms :)
>
>  -David
>
>
>
>  On Thu, Apr 3, 2008 at 6:00 PM, Lachlan Andrew <lachlan.andrew@gmail.com> wrote:
>  > Greetings all,
>  >
>  >  Apologies if this is a dumb question, but why does
>  >  tcp_reno_min_cwnd()  return  ssthresh/2?
>  >
>  >  Since   ssthresh <- snd_cwnd/2   on loss, this looks like it tries to
>  >  reduce  snd_cwnd  to 1/4 its value before a loss event, presumably
>  >  then slow-starting back to half of the original  snd_cwnd.
>  >
>  >  As Tom Quetchenbach pointed out, it is also odd that  omitting
>  >  min_cwnd()  from a congestion control module causes  ssthresh  to be
>  >  used, giving different results from using  tcp_reno_min_cwnd().
>  >
>  >  Thanks,
>  >  Lachlan
>  >
>  >  --
>  >  Lachlan Andrew  Dept of Computer Science, Caltech
>  >  1200 E California Blvd, Mail Code 256-80, Pasadena CA 91125, USA
>  >  Ph: +1 (626) 395-8820    Fax: +1 (626) 568-3603
>  >  http://netlab.caltech.edu/lachlan
>  >  --
>  >  To unsubscribe from this list: send the line "unsubscribe netdev" in
>  >  the body of a message to majordomo@vger.kernel.org
>  >  More majordomo info at  http://vger.kernel.org/majordomo-info.html
>  >
>
>
>
>  --
>  Xiaoliang "David" Wei
>  http://davidwei.org
>  ***********************************************
>
>
> --
>  To unsubscribe from this list: send the line "unsubscribe netdev" in
>  the body of a message to majordomo@vger.kernel.org
>  More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
