From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: About disabling congestion control
Date: Fri, 07 Jan 2011 11:33:44 +0100
Message-ID: <1294396424.3306.7.camel@edumazet-laptop>
References: <AANLkTin53drsv18TZ0CPZM7==6G=rK6vScUb=SCQ4-xr@mail.gmail.com>
	 <20110106173758.37bfef4d@nehalam>
	 <AANLkTi=FLGM1z0VLH+WZXvF=7TZHtMhxLe+KRF3ojWR1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	Michael Kerrisk <mtk.manpages@gmail.com>
To: Syed Obaid Amin <obaidasyed@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:58442 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751470Ab1AGKdt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jan 2011 05:33:49 -0500
Received: by wwa36 with SMTP id 36so18345973wwa.1
        for <netdev@vger.kernel.org>; Fri, 07 Jan 2011 02:33:48 -0800 (PST)
In-Reply-To: <AANLkTi=FLGM1z0VLH+WZXvF=7TZHtMhxLe+KRF3ojWR1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 07 janvier 2011 =C3=A0 05:04 -0500, Syed Obaid Amin a =C3=A9=
crit :
> Thanks for the reply. Yes I also thought to create a sort of NULL
> congestion control type that does nothing. But this way the changes
> would be system wide. BTW, would some one share the insight that why
> linux uses sysctl to select a congestion control algorithm instead of
> socket options.

Hmm, maybe "man 7 tcp" is not up2date.

It mentions TCP_CONGESTION once but doesnt describe it.

CC Michael Kerrisk <mtk.manpages@gmail.com> ;)

http://www.kernel.org/doc/man-pages/online/pages/man7/tcp.7.html


Lets say you have a kernel with support for two congestion controls :

# cat /proc/sys/net/ipv4/tcp_allowed_congestion_control
cubic reno
# cat /proc/sys/net/ipv4/tcp_congestion_control
cubic


Therefore, default is cubic, but you can change to reno if you want.


setsockopt(sock, SOL_TCP, TCP_CONGESTION, "reno", strlen("reno"));



