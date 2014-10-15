From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: something is wrong in commit 971f10eca1 - tcp: better
 TCP_SKB_CB layout to reduce cache line misses
Date: Wed, 15 Oct 2014 04:27:02 -0700
Message-ID: <1413372422.17365.10.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAFrEnehWNzmzZGV-ZGbZF=wJ1q0TjFtB1yG6Dp1yVrJmBj9B7Q@mail.gmail.com>
	 <20141014.164705.1874094084240216813.davem@davemloft.net>
	 <CAFrEnejET5wer6S6qx13tMKWMshmRj+JnQeZL-zdPGcs__9NoQ@mail.gmail.com>
	 <20141014.171559.1355616486999711590.davem@davemloft.net>
	 <CAHA+R7PyUZyjHPf-SJRiiOw=jQjJnXVaosYU7TuiVe6sQTC9Ww@mail.gmail.com>
	 <1413323024.17109.11.camel@edumazet-glaptop2.roam.corp.google.com>
	 <543E4DD8.80203@winsoft.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <cwang@twopensource.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Krzysztof Kolasa <kkolasa@winsoft.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:62079 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752198AbaJOL1E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2014 07:27:04 -0400
Received: by mail-pd0-f176.google.com with SMTP id fp1so1090689pdb.7
        for <netdev@vger.kernel.org>; Wed, 15 Oct 2014 04:27:03 -0700 (PDT)
In-Reply-To: <543E4DD8.80203@winsoft.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-10-15 at 12:35 +0200, Krzysztof Kolasa wrote:
> W dniu 14.10.2014 o 23:43, Eric Dumazet pisze:
> > On Tue, 2014-10-14 at 14:24 -0700, Cong Wang wrote:
> >
> >> Since we are still in merge window, I don't think we have to use
> >> a one-line fix for a bug introduced in this merge window.
> > You are clearly refactoring here. Its a nice cleanup.
> >
> > If I was the maintainer, I would prefer the one line fix.
> >
> > Then when net-next is open, you refactor.
> >
> > As I said, I wont argue, do whatever you want.
> >
> > Thanks
> >
> >
> >
> 
> one-line patch not resolve problem, fix created by Cong Wang resolves 
> problem !!!

Hmm, there should be no difference with either patch.

tcp_v4_rcv() 
...
memmove(&TCP_SKB_CB(skb)->header.h4, IPCB(skb),
        sizeof(struct inet_skb_parm));
...
-> tcp_v4_do_rcv() 
   ->  tcp_v4_hnd_req()
      -> cookie_v4_check(... , &TCP_SKB_CB(skb)->header.h4.opt)

Hmm...
