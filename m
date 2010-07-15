From: "H.K. Jerry Chu" <hkjerry.chu@gmail.com>
Subject: Re: Raise initial congestion window size / speedup slow start?
Date: Wed, 14 Jul 2010 21:51:51 -0700
Message-ID: <AANLkTil3MVGwJUG12dikut9X1s9Ozc_3GwMjx_gErvxI@mail.gmail.com>
References: <4C3D94E3.9080103@wildgooses.com>
	<4C3DD5EB.9070908@tmr.com>
	<20100714.111553.104052157.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davidsen@tmr.com, lists@wildgooses.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:54396 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932267Ab0GOEvw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jul 2010 00:51:52 -0400
In-Reply-To: <20100714.111553.104052157.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 14, 2010 at 11:15 AM, David Miller <davem@davemloft.net> wr=
ote:
> From: Bill Davidsen <davidsen@tmr.com>
> Date: Wed, 14 Jul 2010 11:21:15 -0400
>
>> You may have to go into /proc/sys/net/core and crank up the
>> rmem_* settings, depending on your distribution.
>
> You should never, ever, have to touch the various networking sysctl
> values to get good performance in any normal setup. =A0If you do, it'=
s a
> bug, report it so we can fix it.

Agreed, except there are indeed bugs in the code today in that the
code in various places assumes initcwnd as per RFC3390. So when
initcwnd is raised, that actual value may be limited unnecessarily by
the initial wmem/sk_sndbuf.

Will try to find time to submit a patch.

Jerry

>
> I cringe every time someone says to do this, so please do me a favor
> and don't spread this further. :-)
>
> For one thing, TCP dynamically adjusts the socket buffer sizes based
> upon the behavior of traffic on the connection.
>
> And the TCP memory limit sysctls (not the core socket ones) are sized
> based upon available memory. =A0They are there to protect you from
> situations such as having so much memory dedicated to socket buffers
> that there is none left to do other things effectively. =A0It's a
> protective limit, rather than a setting meant to increase or improve
> performance. =A0So like the others, leave these alone too.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
