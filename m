From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH iproute2 3/3] ss: Unify tcp stats output
Date: Tue, 20 Jan 2015 13:06:47 +0200
Message-ID: <20150120110647.GA17288@angus-think.wlc.globallogic.com>
References: <1421613815-6635-1-git-send-email-vadim4j@gmail.com>
 <1421613815-6635-4-git-send-email-vadim4j@gmail.com>
 <CAPh34mdi+8wLaUY3ZBks40wbOtdzsbTrmuvsHivRouc9rs3gig@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vadim Kochan <vadim4j@gmail.com>, netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:57975 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752467AbbATLRZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 06:17:25 -0500
Received: by mail-wg0-f47.google.com with SMTP id n12so6520871wgh.6
        for <netdev@vger.kernel.org>; Tue, 20 Jan 2015 03:17:24 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CAPh34mdi+8wLaUY3ZBks40wbOtdzsbTrmuvsHivRouc9rs3gig@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 20, 2015 at 11:29:53AM +0100, Hagen Paul Pfeifer wrote:
> On 18 January 2015 at 21:43, Vadim Kochan <vadim4j@gmail.com> wrote:
> 
> Hey Stephen,
> 
> it is time to think about the format of the ss output - it starts to
> get unreadable. Neither humans nor scripts will parse the output. See
> the patch at the end,to get idea what I mean: who will understand
> "fallback_mode"? I don't want to blame someone - not at all, it is
> just one example. My proposal:
> 
> 1) support grouping. E.g. DCTCP could be separated in the following
> manner. I.e. "dctcp:[ ce_state: %d, alpha: %d, ...  ]" or
> "dctcp:ce_state.%d;alpha,%d" like the socket memory output.

For me the current socket memory output looks weird, I think this one can be
better:
    skmem:(rd=%s,rcv_buf=%s,wr=%s,snd_buf=%s,fwd=%s,wr_queue=%s,oth=%s)

>     This makes it easier for humans and scripts to parse the output.
> Since some time ss output is extended really extensive (especially
> Eric make use of this). This is not the end and additional values are
> added - make the current babylon even worse.
> 
> 2) add a JSON formater as soon as possible to make the output
> parseable. I would do this - it is required anyway.
> 
> Any comments on this?
> 
> > +       if (s->ssthresh)
> > +               printf(" ssthresh:%d", s->ssthresh);
> > +
> > +       if (s->dctcp && s->dctcp->enabled) {
> > +               struct dctcpstat *dctcp = s->dctcp;
> > +
> > +               printf(" ce_state %u alpha %u ab_ecn %u ab_tot %u",
> > +                               dctcp->ce_state, dctcp->alpha, dctcp->ab_ecn,
> > +                               dctcp->ab_tot);
> > +       } else if (s->dctcp) {
> > +               printf(" fallback_mode");
> > +       }
> > +
> > +       if (s->send_bps)
> > +               printf(" send %sbps", sprint_bandw(b1, s->send_bps));

And what about processes list ? I think it would be good to have
something like:

u_str  ESTAB      0      0                  * 14046            * 8801
    process:("process#0",pid=535,fd=2)
            ("process#1",pid=535,fd=1)
            ("process#2",pid=535,fd=1)

Instead of:
u_str  ESTAB      0      0                  * 14046            * 8801
    users:(("qtile",pid=535,fd=2),("qtile",pid=535,fd=1))
