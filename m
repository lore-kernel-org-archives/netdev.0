From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: r8169 :  always copying the rx buffer to new skb
Date: Fri, 29 Apr 2011 06:54:40 +0200
Message-ID: <1304052880.2954.18.camel@edumazet-laptop>
References: <4DAC7001.9060800@hotmail.com>
	 <1303147676.2857.20.camel@bwh-desktop> <4DACAC7E.4070400@hotmail.com>
	 <20110420191316.GA18805@electric-eye.fr.zoreil.com>
	 <4DAFA9F9.5080909@hotmail.com> <4DB77D03.9070507@hotmail.com>
	 <20110427203544.GB19708@electric-eye.fr.zoreil.com>
	 <4DBA1A9A.3000703@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>, nic_swsd@realtek.com
To: John Lumby <johnlumby@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:47206 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751154Ab1D2Eyr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2011 00:54:47 -0400
Received: by wwa36 with SMTP id 36so3889699wwa.1
        for <netdev@vger.kernel.org>; Thu, 28 Apr 2011 21:54:46 -0700 (PDT)
In-Reply-To: <4DBA1A9A.3000703@hotmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 28 avril 2011 =C3=A0 21:55 -0400, John Lumby a =C3=A9crit :
> *
>    Conclusions  :
>      . setting copybreak to 16383 seems to be a valid way of avoiding=
=20
> alloc failures when under heavy memory pressure,  although the alloc=20
> failures don't seem to cause much trouble in these runs.
>      .  But I am surprised to see how well the copybreak=3D16383 case=
 runs=20
> with no memory pressure,   much better than I saw for the unpatched=20
> 2.6.39rc2 earlier on,  and I need to run some more tests to check=20
> that.     I will also run same tests on the vanilla 2.6.39.

Doing the copy of data and building an exact size skb has benefit of
providing 'right' skb->truesize (might reduce RCVBUF contention and
avoid backlog drops) and already cached data (hot in cpu caches). Next
'copy' is almost free (L1 cache access)

It all depends on workload. If you want to receive a huge number of
small datagrams, [and feed them to several cpus], results might be
completely different.


>     .    for my next patch submission  -   what should I base it on? =
   =20
> Is there a git project which has the "latest" version of r8169.c?    =
I=20
> think it's not  torvalds/linux-2.6.git as fixes to r8169.c in that=20
> project go only to 2011-03-21.   Sorry if this is dumb question.

This one ?

http://git.kernel.org/?p=3Dlinux/kernel/git/davem/net-next-2.6.git



