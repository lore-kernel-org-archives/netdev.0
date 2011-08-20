From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH v2] Proportional Rate Reduction for TCP.
Date: Sat, 20 Aug 2011 15:41:36 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.1108201534590.24318@melkinpaasi.cs.helsinki.fi>
References: <1313134197-5082-1-git-send-email-nanditad@google.com> <1313739212-2315-1-git-send-email-nanditad@google.com> <alpine.DEB.2.00.1108191312170.12780@wel-95.cs.helsinki.fi> <CAB_+Fg4z46iLv29jX6dXK6GSBbnPxWroq99V6Yr25vpCYrJBqw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="8323329-419827250-1313843772=:24318"
Cc: "David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	Matt Mathis <mattmathis@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Nandita Dukkipati <nanditad@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:51454 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751697Ab1HTMli (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Aug 2011 08:41:38 -0400
In-Reply-To: <CAB_+Fg4z46iLv29jX6dXK6GSBbnPxWroq99V6Yr25vpCYrJBqw@mail.gmail.com>
Content-ID: <alpine.DEB.2.00.1108201537160.24318@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-419827250-1313843772=:24318
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.DEB.2.00.1108201537161.24318@melkinpaasi.cs.helsinki.fi>

On Fri, 19 Aug 2011, Nandita Dukkipati wrote:

> Forgot to turn off gmail's rich formatting, so re-sending to the list.
> 
> On Fri, Aug 19, 2011 at 3:25 AM, Ilpo Järvinen
> <ilpo.jarvinen@helsinki.fi> wrote:
> >
> > On Fri, 19 Aug 2011, Nandita Dukkipati wrote:
> >
> > > +static void tcp_update_cwnd_in_recovery(struct sock *sk, int newly_acked_sacked,
> > > +                                     int fast_rexmit, int flag)
> > > +{
> > > +     struct tcp_sock *tp = tcp_sk(sk);
> > > +     int sndcnt = 0;
> > > +     int delta = tp->snd_ssthresh - tcp_packets_in_flight(tp);
> > > +
> > > +     if (tcp_packets_in_flight(tp) > tp->snd_ssthresh) {
> > > +             if (WARN_ON(!tp->prior_cwnd))
> > > +                     tp->prior_cwnd = 1;
> >
> > This should still be made larger to avoid problems if it ever will be
> > needed.
> 
> I am letting the value remain at 1, mainly because this is the valid
> lowest non-zero value for snd_cwnd to take on. The main purpose of
> this code is to catch any lurking bug outside of PRR which results in
> an undesirable divide by 0 in PRR. I would like to fix that bug if I
> find this code is executed.

NACK, until this value is at least 2 * tp->snd_ssthresh. Or alternatively 
the fallback is removed so that we DBZ and do not end up wrecking the 
network.

Other than that I'm ok with the patch (assuming the branches I brought
up earlier is ok for everybody else).


-- 
 i.
--8323329-419827250-1313843772=:24318--
