From: "Xiaoliang \"David\" Wei" <davidwei79@gmail.com>
Subject: Re: Why is tcp_reno_min_cwnd() ssthresh/2?
Date: Thu, 3 Apr 2008 19:35:50 -0700
Message-ID: <7335583a0804031935g49a843dbq8b8c132411501a8b@mail.gmail.com>
References: <aa7d2c6d0804031800r7d796b40oc011e684bcd2f0c0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: "Lachlan Andrew" <lachlan.andrew@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:16242 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755805AbYDDCfw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2008 22:35:52 -0400
Received: by fg-out-1718.google.com with SMTP id l27so3611414fgb.17
        for <netdev@vger.kernel.org>; Thu, 03 Apr 2008 19:35:50 -0700 (PDT)
In-Reply-To: <aa7d2c6d0804031800r7d796b40oc011e684bcd2f0c0@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Lachlan,

    I think the reno_min_cwnd gives a lower bound of the cwnd during
one round of rate halving. So it is not *always* that cwnd will go to
reno_min_cwnd. If the recovery is done before the cwnd dropping to
reno_min_cwnd, the cwnd will be drop by at least one half. I think the
assumption is that normally one round of rate-halving will end up with
a half of congestion window so this lower bound is not activated.

    The last time I examined this algorithm, I got the following
document about rate halving:
http://www.psc.edu/networking/papers/FACKnotes/current/

    (It might be possible that the assumptions in this draft might be
out-dated or I misunderstood the algorithms :)

-David

On Thu, Apr 3, 2008 at 6:00 PM, Lachlan Andrew <lachlan.andrew@gmail.com> wrote:
> Greetings all,
>
>  Apologies if this is a dumb question, but why does
>  tcp_reno_min_cwnd()  return  ssthresh/2?
>
>  Since   ssthresh <- snd_cwnd/2   on loss, this looks like it tries to
>  reduce  snd_cwnd  to 1/4 its value before a loss event, presumably
>  then slow-starting back to half of the original  snd_cwnd.
>
>  As Tom Quetchenbach pointed out, it is also odd that  omitting
>  min_cwnd()  from a congestion control module causes  ssthresh  to be
>  used, giving different results from using  tcp_reno_min_cwnd().
>
>  Thanks,
>  Lachlan
>
>  --
>  Lachlan Andrew  Dept of Computer Science, Caltech
>  1200 E California Blvd, Mail Code 256-80, Pasadena CA 91125, USA
>  Ph: +1 (626) 395-8820    Fax: +1 (626) 568-3603
>  http://netlab.caltech.edu/lachlan
>  --
>  To unsubscribe from this list: send the line "unsubscribe netdev" in
>  the body of a message to majordomo@vger.kernel.org
>  More majordomo info at  http://vger.kernel.org/majordomo-info.html
>



-- 
Xiaoliang "David" Wei
http://davidwei.org
***********************************************
