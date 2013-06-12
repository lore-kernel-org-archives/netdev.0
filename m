From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: properly send new data in fast recovery
 in first RTT
Date: Tue, 11 Jun 2013 20:57:55 -0700
Message-ID: <1371009475.3252.53.camel@edumazet-glaptop>
References: <1370990132-27652-1-git-send-email-ycheng@google.com>
	 <CADVnQymM_fasoZ6s=Si=gccQ=wvmdt+0jryWovTxLeZw8e95WA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Yuchung Cheng <ycheng@google.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	Netdev <netdev@vger.kernel.org>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f178.google.com ([209.85.215.178]:62219 "EHLO
	mail-ea0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751252Ab3FLD6A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jun 2013 23:58:00 -0400
Received: by mail-ea0-f178.google.com with SMTP id l15so4497967eak.37
        for <netdev@vger.kernel.org>; Tue, 11 Jun 2013 20:57:59 -0700 (PDT)
In-Reply-To: <CADVnQymM_fasoZ6s=Si=gccQ=wvmdt+0jryWovTxLeZw8e95WA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-06-11 at 19:56 -0400, Neal Cardwell wrote:
> On Tue, Jun 11, 2013 at 6:35 PM, Yuchung Cheng <ycheng@google.com> wrote:
> > Linux sends new unset data during disorder and recovery state if all
> > (suspected) lost packets have been retransmitted ( RFC5681, section
> > 3.2 step 1 & 2, RFC3517 section 4, NexSeg() Rule 2).  One requirement
> > is to keep the receive window about twice the estimated sender's
> > congestion window (tcp_rcv_space_adjust()), assuming the fast
> > retransmits repair the losses in the next round trip.
> >
> > But currently it's not the case on the first round trip in either
> > normal or Fast Open connection, beucase the initial receive window
> > is identical to (expected) sender's initial congestion window. The
> > fix is to double it.
> >
> > Signed-off-by: Yuchung Cheng <ycheng@google.com>
> 
> Acked-by: Neal Cardwell <ncardwell@google.com>

Yes, this is indeed a very nice catch, thanks Yuchung !

Acked-by: Eric Dumazet <edumazet@google.com>
