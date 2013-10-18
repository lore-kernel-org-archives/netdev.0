From: Nandita Dukkipati <nanditad@google.com>
Subject: Re: [PATCH net] tcp: fix incorrect ca_state in tail loss probe
Date: Fri, 18 Oct 2013 10:29:00 -0700
Message-ID: <CAB_+Fg5k5qKG=1T30=+BXZaWGoLsREGMg2ZuEJwky_OBm_AJ5w@mail.gmail.com>
References: <1381598187-9681-1-git-send-email-ycheng@google.com>
	<CADVnQymADSKHr6oxr6dN8gdjxf-vtCXOd6xm3neRcWLp7nh9Qg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Yuchung Cheng <ycheng@google.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, michael@sterretts.net,
	jwboyer@fedoraproject.org,
	"Steinar H. Gunderson" <sesse@google.com>,
	dormando <dormando@rydia.net>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:64380 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756445Ab3JRR3B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 13:29:01 -0400
Received: by mail-ie0-f171.google.com with SMTP id tp5so6924682ieb.2
        for <netdev@vger.kernel.org>; Fri, 18 Oct 2013 10:29:01 -0700 (PDT)
In-Reply-To: <CADVnQymADSKHr6oxr6dN8gdjxf-vtCXOd6xm3neRcWLp7nh9Qg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 13, 2013 at 10:55 PM, Neal Cardwell <ncardwell@google.com> wrote:
>
> On Sat, Oct 12, 2013 at 1:16 PM, Yuchung Cheng <ycheng@google.com> wrote:
> > On receiving an ACK that covers the loss probe sequence, TLP
> > immediately sets the congestion state to Open, even though some packets
> > are not recovered and retransmisssion are on the way.  The later ACks
> > may trigger a WARN_ON check in step D of tcp_fastretrans_alert(), e.g.,
> > https://bugzilla.redhat.com/show_bug.cgi?id=989251
> >
> > The fix is to follow the similar procedure in recovery by calling
> > tcp_try_keep_open(). The sender switches to Open state if no packets
> > are retransmissted. Otherwise it goes to Disorder and let subsequent
> > ACKs move the state to Recovery or Open.
> >
> > Reported-By: Michael Sterrett <michael@sterretts.net>
> > Tested-By: Dormando <dormando@rydia.net>
> > Signed-off-by: Yuchung Cheng <ycheng@google.com>
>
> Acked-by: Neal Cardwell <ncardwell@google.com>

Acked-by: Nandita Dukkipati <nanditad@google.com>
