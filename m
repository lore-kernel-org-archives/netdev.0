From: Tom Herbert <therbert@google.com>
Subject: Re: Raise initial congestion window size / speedup slow start?
Date: Wed, 14 Jul 2010 21:12:33 -0700
Message-ID: <AANLkTikTyZGQWWIBzYSQWpUK30xxbMXLbJXeHahWnlIi@mail.gmail.com>
References: <4C3D94E3.9080103@wildgooses.com>
	<4C3DD5EB.9070908@tmr.com>
	<20100714.111553.104052157.davem@davemloft.net>
	<4C3E0684.5060409@wildgooses.com>
	<4C3E1B54.40604@hp.com>
	<20100714203919.GD6682@nuttenaction>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rick Jones <rick.jones2@hp.com>, Ed W <lists@wildgooses.com>,
	David Miller <davem@davemloft.net>, davidsen@tmr.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Jerry Chu <hkchu@google.com>,
	Nandita Dukkipati <nanditad@google.com>
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100714203919.GD6682@nuttenaction>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 14, 2010 at 1:39 PM, Hagen Paul Pfeifer <hagen@jauu.net> wr=
ote:
> * Rick Jones | 2010-07-14 13:17:24 [-0700]:
>
>>There is an effort under way, lead by some folks at Google and
>>including some others, to get the RFC's enhanced in support of the
>>concept of larger initial congestion windows. =A0Some of the discussi=
on
>>may be in the "tcpm" mailing list (assuming I've not gotten my
>>mailing lists confused). =A0There may be some previous discussion of
>>that work in the netdev archives as well.
>
> tcpm is the right mailing list but there is currently no effort to de=
velop
> this topic. Why? Because is not a standardization issue, rather it is=
 a
> technical issue. You cannot rise the initial CWND and expect a fair b=
ehavior.
> This was discussed several times and is documented in several documen=
ts and
> RFCs.
>
> RFC 5681 Section 3.1. Google employees should start with Section 3. T=
his topic
> pop's of every two months in netdev and until now I _never_ read a
> consolidated contribution.
>

There is an Internet draft
(http://datatracker.ietf.org/doc/draft-hkchu-tcpm-initcwnd/) on
raising the default Initial Congestion window to 10 segments, as well
as a SIGCOMM paper (http://ccr.sigcomm.org/online/?q=3Dnode/621).  We
presented this proposal and data supporting it at Anaheim IETF, and
will be following up in Netherlands with more data including some of
which should further address fairness questions.

In terms of Linux implementation, setting ICW via ip route is
sufficient support on the server side.  There is also a proposed patch
which could allow applications to set ICW themselves (in hopes that
application can reduce number of simultaneous connections).  On the
client side we can now adjust the receive window to advertise larger
initial windows.  Among current implementations, Linux advertises the
smallest default receive window of major OSes, so it turns out Linux
clients won't get lower latency benefits currently (so we'll probably
ask to raise the default some day :-)).

Tom

> Partial local issues can already be "fixed" via route specific ip opt=
ions -
> see initcwnd.
>
> HGN
>
>
>
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
