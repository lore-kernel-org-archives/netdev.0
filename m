From: tsuna <tsunanet@gmail.com>
Subject: Re: [PATCH] tcp: Expose the initial RTO via a new sysctl.
Date: Tue, 31 May 2011 07:48:09 -0700
Message-ID: <BANLkTimqtjskX5q2ovTp_c05MdqBDOWsRg@mail.gmail.com>
References: <1305715384-81716-1-git-send-email-tsunanet@gmail.com>
 <20110518.152653.1486764697527722925.davem@davemloft.net> <BANLkTik-6wh8=jb6oMEpJvYC8+KTGGsMsw@mail.gmail.com>
 <20110518.155200.801089483916944725.davem@davemloft.net> <20110518202025.GC4175@nuttenaction>
 <BANLkTimtA9BB7g5cOm8c9sGChQjf1P0Q-Q@mail.gmail.com> <fc49a1b4c32eee9b5cbfbeec4729eef5@localhost>
 <BANLkTi=p1V1x+y=-cH-Q7bvueu_4_D1ywQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Hagen Paul Pfeifer <hagen@jauu.net>,
	David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "H.K. Jerry Chu" <hkjerry.chu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:57458 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751265Ab1EaOsa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2011 10:48:30 -0400
In-Reply-To: <BANLkTi=p1V1x+y=-cH-Q7bvueu_4_D1ywQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 20, 2011 at 5:06 PM, H.K. Jerry Chu <hkjerry.chu@gmail.com> wrote:
> Yep, that's why we've had a knob for this for years.

I was traveling last week so sorry for not replying earlier to various
comments people made.

I talked to Jerry and he's agreed to share some patches that Google
has been using internally for years.  I started this work because
after leaving Google and taking these changes for granted, I was
surprised to find that they weren't actually part of the mainline
Linux kernel.

It seems that David is willing to accept a change that will lower the
initRTO to 1s (compile-time constant), with a fallback to 3s
(compile-time constant), as per the draft rfc2988bis.  Others are
legitimately worried about the impact this would cause in environments
where RTT is typically (or always) in the 1-3s range.  Some would like
to see this as a per-destination thing.

Personally what I think would be ideal would be:
  1. A sysctl knob for initRTO, to allow people to adjust this
appropriately for their environment.
  2. Apply the srtt / rttvar seen on previous connections to new connections.

Does that sound reasonable?

For 2), I'm not sure how the details would work yet, I believe the
kernel already has what's necessary to remember these things on a per
peer basis, but it would be nice if I could specify things like "for
10.x.0.0/16 (local datacenter) use this aggressive setting, for
10.0.0.0/8 (my internal backend network) use that, for everything else
(Internets etc.) use the default".

-- 
Benoit "tsuna" Sigoure
Software Engineer @ www.StumbleUpon.com
