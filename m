From: Lars Melin <larsm17@gmail.com>
Subject: Re: [PATCH net-next v2 00/12] cdc_ncm: add buffer tuning and stats
 using ethtool
Date: Mon, 19 May 2014 00:10:29 +0700
Message-ID: <5378E985.1040206@gmail.com>
References: <1400269709-18854-1-git-send-email-bjorn@mork.no>	<20140516.224032.2301577488192248796.davem@davemloft.net>	<87d2fcoqay.fsf@nemi.mork.no> <20140518011917.11270.qmail@stuge.se>	<alpine.LNX.2.03.1405181155310.7743@gmail.com> <87vbt3m98p.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, alexey.orishko@gmail.com,
	oliver@neukum.org, David.Laight@aculab.com
To: =?UTF-8?B?QmrDuHJuIE1vcms=?= <bjorn@mork.no>,
	Peter Stuge <peter@stuge.se>,
	Enrico Mioso <mrkiko.rs@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:44374 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752121AbaERRKn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 May 2014 13:10:43 -0400
In-Reply-To: <87vbt3m98p.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014-05-18 21:50, Bj=C3=B8rn Mork wrote:
> I could be wrong, but my impression is that the userspace API
> preferences for network devices are
>
>   1. ethtool
>   2. sysfs
>   3. module param
>   ..
>   99. ioctl
>
> This is the primary reason why I was looking for someplace to put thi=
s
> within the existing ethtool API.  Using sysfs would have worked fine
> too, I guess.  But is there any real advantage, making it worth a
> switch?  I am all open to change to sysfs instead before v3.16 is
> released, *if* there are good reasons to do it. And no objections.  B=
ut
> I do want more of a reason than the fact that it can be done.  Maybe =
I
> got the preferred order wrong?
>
> I ruled out module parameters early because I believe there are real =
use
> cases requiring different settings per device.  The limited host syst=
em
> resources will of course affect all devices on a single host the same
> way.  But not all devices can cope with the reduced buffers. So there
> should be some way to tune two devices connected to the same host
> differently.
>
> I am not going to say anything about ioctls :-)
>
>
> Bj=C3=B8rn
> --

Your target audience is embedded systems with limited cpu power and=20
buffer memory, right?
If so, then you can't expect them to have ethtool included and their=20
developers are not likely to be happy over having to "waste" another=20
100KB in order to tune a 20KB driver.
My vote goes for sysfs.

/Lars
