From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH] ss: add detail explains of -m, -o, -e and -i
 options in ss man page
Date: Wed, 25 Oct 2017 23:52:21 +0200
Message-ID: <20171025215221.GT32305@orbyte.nwl.cc>
References: <CAG3TDc0XxtkA5TU_GDzdZv1ujuqf09e9kBYQm2p5QGbppt7efw@mail.gmail.com>
 <8560b3clnj.fsf@mojatatu.com>
 <CAG3TDc3_GGuKCz=2c-jTXutNq_rWcig3u5oB9XEyrsK0_yEbTg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roman Mashak <mrv@mojatatu.com>, netdev@vger.kernel.org,
        stephen@networkplumber.org
To: peng yu <yupeng0921@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:38928 "EHLO orbyte.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751421AbdJYVwY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 25 Oct 2017 17:52:24 -0400
Content-Disposition: inline
In-Reply-To: <CAG3TDc3_GGuKCz=2c-jTXutNq_rWcig3u5oB9XEyrsK0_yEbTg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Yupeng,

On Wed, Oct 25, 2017 at 02:20:25PM -0700, peng yu wrote:
> Thanks for your suggestion, below is a new patch. What I did:
> 1. change all 'package' to 'packet'
> 2. put my additional text as second paragraphs of the original options.
> 3. checked the man page by aspell
> If anything else need to fix, please let me know.

Thanks for quickly addressing all mentioned issues! Though here come a
few more (sorry):

Your MUA mangled the patch so it doesn't apply cleanly. Please in
future, use 'git format-patch' and 'git send-email' to avoid this. You
can still add comments to it (like those lines above) by inserting them
below the '---' marker (and above the diff-stat) format-patch usually
inserts. This way these comments won't be included in the commit
message.

More inline:

> commit 9803d27de31028733de789495d78ff7a39385009
> Author: yupeng <yupeng0921@gmail.com>
> Date:   Wed Oct 25 21:12:21 2017 +0000
> 
>     add additional explain in ss man page
> 
>     Add detail explains of -m, -o, -e and -i options, which are not
>     documented anywhere
> 
>     Signed-off-by: Peng Yu <yupeng0921@gmail.com>

You have something set up inconsistently regarding your name here: In
'Author' above it's "yupeng" while in SoB and From address it's "Peng
Yu". This is just a minor nit, but if you set it up consistently, the
submitted patches will appear more clean.

> diff --git a/man/man8/ss.8 b/man/man8/ss.8
> index 3bec97f..401ae3e 100644
> --- a/man/man8/ss.8
> +++ b/man/man8/ss.8
> @@ -37,19 +37,152 @@ Display both listening and non-listening (for TCP
> this means established connect

This is an example of where your MUA mangled the patch, the line above
shouldn't be broken.

>  Display only listening sockets (these are omitted by default).
>  .TP
>  .B \-o, \-\-options
> -Show timer information.
> +Show timer information. For tcp protocol, the output format is:
> +.br

I suggest replacing that explicit line break with:
.RS
.P

> +timer:(<timer_name>,<expire_time>,<retrans>)
> +.br

And this one with:
.P
.TP

> +.B <timer_name>
> +the name of the timer, there are five kind of timer names:
> +.RS
> +.RS

Then drop one of the .RS here.

> +.BR on ": means one of these timers: tcp retrans timer, tcp early
> retrans timer and tail loss probe timer"
> +.br
> +.BR keepalive ": tcp keep alive timer"
> +.br
> +.BR timewait ": timewait stage timer"
> +.br
> +.BR persist ": zero window probe timer"
> +.br
> +.BR unknown ": none of the above timers"
> +.RE

Insert .TP here.

> +.B <expire_time>
> +how long time the timer will expire
> +.br

Replace .br here with .TP and change the other additions equivalently. I
think the result is more readable, what do you think?

Thanks, Phil
