From: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
Subject: Re: [RFC PATCH net-next] tcp: add CDG congestion control
Date: Thu, 4 Jun 2015 17:37:14 +0200
Message-ID: <CA++eYdvtH22M-7t=-aO4mZHRuNRYBvgSXkuHYRRtPN_bjCpzVw@mail.gmail.com>
References: <1431894670-12609-1-git-send-email-kennetkl@ifi.uio.no>
	<20150518151648.6d33128c@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>,
	netdev <netdev@vger.kernel.org>,
	David Hayes <davihay@ifi.uio.no>,
	Yuchung Cheng <ycheng@google.com>,
	Andreas Petlund <apetlund@simula.no>,
	Dave Taht <dave.taht@gmail.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:32878 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932160AbbFDPhQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 11:37:16 -0400
Received: by wiwd19 with SMTP id d19so25688029wiw.0
        for <netdev@vger.kernel.org>; Thu, 04 Jun 2015 08:37:15 -0700 (PDT)
In-Reply-To: <20150518151648.6d33128c@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 19, 2015 at 12:16 AM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
>
> I am really happy to see more congestion control development.

:)

>
> Module parameters make for rather ugly tuning.
> They are ok for testing but difficult to use in real life.

CDG's throughput-delay tradeoff is affected by the parameters window,
backoff_beta, and backoff_factor. Most users will likely use the
default parameters, but others might want to tune them for less
queueing delay, more throughput, slower backoff response, etc.

window is a difficult parameter to get right when tuning; it is
intrinsically RTT-dependent, but also influences CDG's RTT-independent
backoff probability..  For the record, CDG as a congestion control is
still RTT-dependent, e.g., it uses NewReno to grow cwnd.

The upcoming patch renames ineffective_thresh to detect_ineff, and
removes ineffective_hold. Grepping experiment logs, I never once saw
the hold function kick in. A threshold of 5 is also overly
conservative when limiting the shadow window to 2*cwnd; a threshold of
1 is a better starting point.

Thanks to Eric, Yuchung and Stephen for your feedback!
