From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] [net] af_unix: return data from multiple SKBs on
 recv() with MSG_PEEK flag
Date: Sun, 20 Sep 2015 12:21:45 -0700
Message-ID: <1442776905.29850.37.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1442740705-16452-1-git-send-email-aconole@bytheb.org>
	 <1442767564.29850.35.camel@edumazet-glaptop2.roam.corp.google.com>
	 <87twqo7vub.fsf@bytheb.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Aaron Conole <aconole@bytheb.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:33024 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755253AbbITTVr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Sep 2015 15:21:47 -0400
Received: by pacex6 with SMTP id ex6so96241227pac.0
        for <netdev@vger.kernel.org>; Sun, 20 Sep 2015 12:21:46 -0700 (PDT)
In-Reply-To: <87twqo7vub.fsf@bytheb.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2015-09-20 at 15:07 -0400, Aaron Conole wrote:
> Eric Dumazet <eric.dumazet@gmail.com> writes:
> 
> > On Sun, 2015-09-20 at 05:18 -0400, Aaron Conole wrote:
> >> From: Aaron Conole <aaron@bytheb.org>
> >> 
> >
> > I am wondering what this is expected to do, and how this code would
> > possibly not trigger a crash.
> Are you suspecting it should crash from a possible double-lock case?
> On line 2125, there is an unconditional unlock, which should be 
> guaranteeing that there is no longer a condition to 'double lock' the
> socket.

Not at all.

I am suggesting there is a big difference between

unix_state_lock(&sk);

and

unix_state_lock(sk);

Can you see it ?
