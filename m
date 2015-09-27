From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1] net: Add SO_REUSEPORT_LISTEN_OFF socket option as
 drain mode
Date: Sat, 26 Sep 2015 19:24:15 -0700
Message-ID: <1443320655.3273.7.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1443313848-751-1-git-send-email-tolga.ceylan@gmail.com>
	 <877fnc7i0i.fsf@bytheb.org>
	 <CALmu+Sx8L5mWf3Nnbz=x0qt7pC5n5oVPRJd7dnLATVpmmO+nrA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Aaron Conole <aconole@bytheb.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Tolga Ceylan <tolga.ceylan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:36627 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754732AbbI0CYR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Sep 2015 22:24:17 -0400
Received: by pablk4 with SMTP id lk4so44075862pab.3
        for <netdev@vger.kernel.org>; Sat, 26 Sep 2015 19:24:17 -0700 (PDT)
In-Reply-To: <CALmu+Sx8L5mWf3Nnbz=x0qt7pC5n5oVPRJd7dnLATVpmmO+nrA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2015-09-26 at 19:02 -0700, Tolga Ceylan wrote:
> By keeping hiscore/matches as is, I'm trying to keep the hashing consistent.
> Otherwise, this would behave similar to removing a listener which
> drops connections.

Right, this problem will soon disappear when listener rewrite is
complete.

Only SYN packet will have to select a listener.

Then when ACK packet comes, the SYN_RECV will be found in ehash table,
and req->rsk_listener will be used to get the listener that was chosen
at SYN time.
