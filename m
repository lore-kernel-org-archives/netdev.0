From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: [V4.4-rc6 Regression] af_unix: Revert 'lock_interruptible' in stream receive code
Date: Sun, 07 Feb 2016 22:24:22 +0000
Message-ID: <87io20upk9.fsf@doppelsaurus.mobileactivedefense.com>
References: <56B4EF04.2060407@canonical.com>
	<87bn7ude8g.fsf@doppelsaurus.mobileactivedefense.com>
	<1454713398.7627.325.camel@edumazet-glaptop2.roam.corp.google.com>
	<8737t4jr99.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	davem@davemloft.net, hannes@stressinduktion.org,
	edumazet@google.com, dhowells@redhat.com, ying.xue@windriver.com,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"stable\@vger.kernel.org" <stable@vger.kernel.org>,
	Joseph Salisbury <joseph.salisbury@canonical.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tiger.mobileactivedefense.com ([217.174.251.109]:39549 "EHLO
	tiger.mobileactivedefense.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754607AbcBGWYn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Feb 2016 17:24:43 -0500
In-Reply-To: <8737t4jr99.fsf@doppelsaurus.mobileactivedefense.com> (Rainer
	Weikusat's message of "Sun, 07 Feb 2016 18:43:14 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rainer Weikusat <rw@doppelsaurus.mobileactivedefense.com> writes:

[...]

> The start uses that to record an error which might need to be
> reported, the return statement uses it to indicate that an error has
> occurred. Hence, some kind of in-between translation must occur.  The
> mutex_lock_interruptible happened to do that but that was never it's
> intended purpose.

Additional information: The 'trick' of using recvmsg w/o a receive
buffer in order to retrieve control messages in fact wouldn't have
worked with the unix_stream_recvmsg prior to introduction of the
interruptible lock as that (judging from the git source) would have
triggered all the same issues,

	- -EOPNOTSUP if a msg was available

        - -EAGAIN if the code had to wait

        - not receiving the creds if the -EAGAIN hadn't happened because
          of the continue (that's the other patch)

IOW, that's a feature inadvertendly added by an otherwise useless code
change (mea culpa).
