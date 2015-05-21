From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: add tcpi_segs_in and tcpi_segs_out to
 tcp_info
Date: Thu, 21 May 2015 13:06:00 -0700
Message-ID: <1432238760.4060.104.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1430260098-14127-1-git-send-email-edumazet@google.com>
	 <20150512130855.GA29412@localhost.localdomain>
	 <1431462713.566.95.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1432164941.4060.57.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAK6E8=ebJDpUZeM=JHmqxgjcFEr1WLee2UeaKUjPg5vQwVL0tA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Marcelo Ricardo Leitner <mleitner@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Matt Mathis <mattmathis@google.com>,
	Craig Gallek <cgallek@google.com>, Martin Lau <kafai@fb.com>,
	Chris Rapier <rapier@psc.edu>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:35010 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755340AbbEUUGD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 16:06:03 -0400
Received: by iesa3 with SMTP id a3so16761644ies.2
        for <netdev@vger.kernel.org>; Thu, 21 May 2015 13:06:02 -0700 (PDT)
In-Reply-To: <CAK6E8=ebJDpUZeM=JHmqxgjcFEr1WLee2UeaKUjPg5vQwVL0tA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-05-21 at 12:41 -0700, Yuchung Cheng wrote:

> It'd be nice to count SYN and SYNACKs for apps tracking the handshake stats.
> For syn-cookies we can't do much. But for the rest we can account
> req->num_retrans for SYN-ACKs sent, and perhaps track SYN received in
> request sock?

Well, this is partly because we can not guarantee the behavior that I
chose to explicitly state that we were not tracking SYNACK for passive
sessions.

Also TCP_DEFER_ACCEPT comes into play here...

If we want to handle this in a deterministic way, we would have to add
some bit to warn the application reading tcp_info that the session was
initiated after a valid syncookie was received, and that initial value
of tcp_info.tcpi_segs_{in|out} can be wrong.
