From: "Jerry Chu" <hkchu@google.com>
Subject: Re: Socket buffer sizes with autotuning
Date: Mon, 28 Apr 2008 13:44:06 -0700
Message-ID: <d1c2719f0804281344h4b8c98b9w6d7d4d2cbcdee857@mail.gmail.com>
References: <d1c2719f0804231629p4536e98do668b812e34d2b92c@mail.gmail.com>
	 <1e41a3230804240932u510609beh8fb577baaadeb9bd@mail.gmail.com>
	 <d1c2719f0804241749p2c0dd7daofd343bc37a916247@mail.gmail.com>
	 <20080424.234628.170849475.davem@davemloft.net>
	 <d1c2719f0804281130n7b0aaab8t54b2a585cff53a99@mail.gmail.com>
	 <1e41a3230804281221s11442a82j55c363116988a5cb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	rick.jones2@hp.com
To: "John Heffner" <johnwheffner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:61628 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934751AbYD1UoM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2008 16:44:12 -0400
Received: from zps19.corp.google.com (zps19.corp.google.com [172.25.146.19])
	by smtp-out.google.com with ESMTP id m3SKi7RZ028475
	for <netdev@vger.kernel.org>; Mon, 28 Apr 2008 21:44:07 +0100
Received: from hs-out-0708.google.com (hsbx43.prod.google.com [10.44.100.43])
	by zps19.corp.google.com with ESMTP id m3SKhfCJ006577
	for <netdev@vger.kernel.org>; Mon, 28 Apr 2008 13:44:06 -0700
Received: by hs-out-0708.google.com with SMTP id x43so4355764hsb.3
        for <netdev@vger.kernel.org>; Mon, 28 Apr 2008 13:44:06 -0700 (PDT)
In-Reply-To: <1e41a3230804281221s11442a82j55c363116988a5cb@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 28, 2008 at 12:21 PM, John Heffner <johnwheffner@gmail.com> wrote:
>
> On Mon, Apr 28, 2008 at 11:30 AM, Jerry Chu <hkchu@google.com> wrote:
> >  Correct, but its counterpart doesn't exist in tcp_is_cwnd_limited(). So
> >  cwnd will continue to grow when left < cwnd/sysctl_tcp_tso_win_divisor,
> >  which can be very large when cwnd is large.
> >
> >  If I change tcp_tso_win_divisor to 0, cwnd max out at 695 rather than 1037,
> >  exactly off by 1/3. I tried to add the same check to tcp_is_cwnd_limited():
> >
> >  diff -c /tmp/tcp.h.old tcp.h
> >  *** /tmp/tcp.h.old      Mon Apr 28 11:00:44 2008
> >  --- tcp.h       Mon Apr 28 10:54:10 2008
> >  ***************
> >  *** 828,833 ****
> >  --- 828,835 ----
> >                 return 0;
> >
> >         left = tp->snd_cwnd - in_flight;
> >  +       if (left >= 65536)
> >  +               return 0;
> >         if (sysctl_tcp_tso_win_divisor)
> >                 return left * sysctl_tcp_tso_win_divisor < tp->snd_cwnd;
> >         else
> >
> >  >
> >
> >  But it doesn't seem to help (cwnd still grows to 1037).
>
> Cwnd is in packets, not bytes.

Yes, of course.

>
> Try this series of patches, against net-next.

Ah, you already know about this problem. Yes it does the trick.

Jerry

>
>  -John
>
