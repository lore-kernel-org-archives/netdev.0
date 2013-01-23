From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Linux 3.6.x kernel crash in tcp_slow_start / bictcp_cong_avoid
 with wfica
Date: Wed, 23 Jan 2013 15:47:11 -0800
Message-ID: <1358984831.12374.1227.camel@edumazet-glaptop>
References: <20130123161238.GE8912@reaktio.net>
	 <20130123214445.GA16641@order.stressinduktion.org>
	 <20130123215151.GF8912@reaktio.net>
	 <20130123152642.4a8389ba@nehalam.linuxnetplumber.net>
	 <20130123234116.GC16641@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Pasi =?ISO-8859-1?Q?K=E4rkk=E4inen?= <pasik@iki.fi>,
	netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:51799 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752332Ab3AWXrO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 18:47:14 -0500
Received: by mail-pa0-f46.google.com with SMTP id kp14so3683660pab.5
        for <netdev@vger.kernel.org>; Wed, 23 Jan 2013 15:47:13 -0800 (PST)
In-Reply-To: <20130123234116.GC16641@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-01-24 at 00:41 +0100, Hannes Frederic Sowa wrote:
> On Wed, Jan 23, 2013 at 03:26:42PM -0800, Stephen Hemminger wrote:
> > I see no problems when using Citrix.
> > This is a normal strace of the program wifca (in idle loop)
> 
> Thanks, could you also have a look at setsockopts while socket creation and
> connection establishment?

As I said, tp->snd_cwnd is set to 0 by a bug in TCP stack.

Probably a combination of changed sysctls, and a genuine bug.

Please give us /etc/sysctl.conf content.

Adding some BUG_ON(!tp->snd_cwnd) on every writes to tp->snd_cwnd should
catch the bug.
